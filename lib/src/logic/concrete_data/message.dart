import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

import 'user.dart';

export 'user.dart';

class Message extends Identifiable<String> {
  String? id;
  DateTime? date;
  String? role;
  User? user;
  String? title;
  String? body;

  Message();

  static const className = 'Message';

  static Message? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Message();
    decoded.id = decoder.decodeId();
    decoded.date = decoder.decodeDate('date');
    decoded.role = decoder.decodeString('role');
    decoded.user = User.decode(decoder.getDecoder('user'));
    decoded.title = decoder.decodeString('title');
    decoded.body = decoder.decodeString('body');
    return decoded;
  }
}
