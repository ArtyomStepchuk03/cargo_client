import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/fixed_items_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/map_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/format/role.dart';
import 'package:manager_mobile_client/src/ui/format/user.dart';
import 'package:manager_mobile_client/src/ui/validators/required_validator.dart';
import 'message_write_strings.dart' as strings;
import 'user_data_source.dart';

class MessageRecipientsSearchPredicate implements SearchPredicate<MessageRecipients> {
  bool call(MessageRecipients object, String query) {
    final user = object.user;
    if (user == null) {
      return false;
    }
    if (user.role == Role.logistician) {
      return satisfiesQuery(user.logistician.name, query);
    }
    if (user.role == Role.manager) {
      return satisfiesQuery(user.manager.name, query);
    }
    if (user.role == Role.dispatcher) {
      return satisfiesQuery(user.dispatcher.name, query);
    }
    if (user.role == Role.driver) {
      return satisfiesQuery(user.driver.name, query);
    }
    if (user.role == Role.customer) {
      return satisfiesQuery(user.customer.name, query);
    }
    if (user.role == Role.supplier) {
      return satisfiesQuery(user.supplier.name, query);
    }
    return false;
  }
}

Widget buildMessageRecipientsFormField({
  DependencyState dependencyState,
  Key key,
  MessageRecipients initialValue,
}) {
  return LoadingListFormField<MessageRecipients>(
    key: key,
    initialValue: initialValue,
    dataSource: FixedItemsDataSource(
      MapDataSource(
        SkipPagedDataSourceAdapter(
          CachedSkipPagedDataSource(
            UserDataSource(dependencyState.network.serverAPI.users, [Role.manager, Role.dispatcher, Role.driver, Role.customer, Role.supplier]),
            dependencyState.caches.messageUser
          )
        ),
        (user) => MessageRecipients.user(user),
      ),
      [
        MessageRecipients.all(),
        MessageRecipients.role(Role.manager),
        MessageRecipients.role(Role.customer),
        MessageRecipients.role(Role.dispatcher),
        MessageRecipients.role(Role.driver),
      ],
    ),
    searchPredicate: MessageRecipientsSearchPredicate(),
    formatter: (recipients) {
      if (recipients == null) {
        return '';
      }
      if (recipients.user != null) {
        return formatUserSafe(recipients.user);
      }
      if (recipients.role != null) {
        return formatRole(recipients.role);
      }
      return strings.allUsers;
    },
    listViewBuilder: (context, recipients) {
      if (recipients.user != null) {
        return SimpleListTile(formatUserSafe(recipients.user), formatRole(recipients.user.role));
      }
      if (recipients.role != null) {
        return SimpleListTile(formatRole(recipients.role));
      }
      return SimpleListTile(strings.allUsers);
    },
    onRefresh: dependencyState.caches.messageUser.clear,
    label: strings.recipients,
    validator: RequiredValidator(),
  );
}
