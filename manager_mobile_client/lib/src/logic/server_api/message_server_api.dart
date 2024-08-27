import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/message.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/message.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class MessageRecipients {
  final bool all;
  final String role;
  final User user;

  MessageRecipients.all() : this._(all: true);
  MessageRecipients.role(String role) : this._(role: role);
  MessageRecipients.user(User user) : this._(user: user);

  @override
  bool operator==(dynamic other) {
    if (other is! MessageRecipients) {
      return false;
    }
    final MessageRecipients otherMessageRecipients = other;
    return all == otherMessageRecipients.all && role == otherMessageRecipients.role && user == otherMessageRecipients.user;
  }

  @override
  int get hashCode {
    if (user != null) {
      return user.hashCode;
    }
    if (role != null) {
      return role.hashCode;
    }
    return all.hashCode;
  }

  MessageRecipients._({this.all, this.role, this.user});
}

class MessageServerAPI implements SkipPagedDataSource<Message> {
  final ServerManager serverManager;

  MessageServerAPI(this.serverManager);

  Future<List<Message>> list(int skip, int limit) async {
    final builder = parse.QueryBuilder(Message.className);
    builder.include('user');
    builder.include('user.manager');
    builder.include('user.dispatcher');
    builder.include('user.driver');
    builder.include('user.customer');
    builder.include('user.supplier');
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('date');
    final results = await builder.find(serverManager.server);
    return results.map((json) => Message.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<Message> getLast(User user) async {
    var messages = <Message>[];
    final lastBroadcast = await _getLastBroadcast();
    final lastForRole = await _getLastForRole(user.role);
    final lastForUser = await _getLastForUser(user);
    if (lastBroadcast != null) messages.add(lastBroadcast);
    if (lastForRole != null) messages.add(lastForRole);
    if (lastForUser != null) messages.add(lastForUser);
    if (messages.isEmpty) {
      return null;
    }
    messages.sort((one, other) => one.date.compareTo(other.date));
    return messages.last;
  }

  Future<void> send(MessageRecipients recipients, String title, String body) async {
    final parameters = {
      if (recipients.user != null)
        'userId': recipients.user.id
      else if (recipients.role != null)
        'role': recipients.role
      else
        'all': recipients.all,
      'title': title,
      'body': body,
    };
    await callCloudFunction(serverManager.server, 'Dispatcher_sendMessage', parameters);
  }

  Future<void> delete(Message message) async {
    await parse.delete(serverManager.server, Message.className, message.id);
  }

  @override
  bool operator==(dynamic other) => other is MessageServerAPI;

  @override
  int get hashCode => super.hashCode;

  Future<Message> _getLastBroadcast() async {
    final builder = parse.QueryBuilder(Message.className);
    builder.doesNotExist('role');
    builder.doesNotExist('user');
    builder.addDescending('date');
    final result = await builder.findFirst(serverManager.server);
    return Message.decode(Decoder(result));
  }

  Future<Message> _getLastForRole(String role) async {
    final builder = parse.QueryBuilder(Message.className);
    builder.equalTo('role', role);
    builder.doesNotExist('user');
    builder.addDescending('date');
    final result = await builder.findFirst(serverManager.server);
    return Message.decode(Decoder(result));
  }

  Future<Message> _getLastForUser(User user) async {
    final builder = parse.QueryBuilder(Message.className);
    builder.doesNotExist('role');
    builder.equalToUserObject('user', user.id);
    builder.addDescending('date');
    final result = await builder.findFirst(serverManager.server);
    return Message.decode(Decoder(result));
  }
}
