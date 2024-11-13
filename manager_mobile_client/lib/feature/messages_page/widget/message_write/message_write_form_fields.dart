import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/fixed_items_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/map_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/util/format/role.dart';
import 'package:manager_mobile_client/util/format/user.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

import 'user_data_source.dart';

class MessageRecipientsSearchPredicate
    implements SearchPredicate<MessageRecipients> {
  bool call(MessageRecipients object, String query) {
    final user = object.user;

    switch (user.role) {
      case Role.logistician:
        return satisfiesQuery(user.logistician.name, query);
      case Role.manager:
        return satisfiesQuery(user.manager.name, query);
      case Role.dispatcher:
        return satisfiesQuery(user.dispatcher.name, query);
      case Role.driver:
        return satisfiesQuery(user.driver.name, query);
      case Role.customer:
        return satisfiesQuery(user.customer.name, query);
      case Role.supplier:
        return satisfiesQuery(user.supplier.name, query);
      default:
        return false;
    }
  }
}

Widget buildMessageRecipientsFormField(
  BuildContext context, {
  DependencyState dependencyState,
  Key key,
  MessageRecipients initialValue,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<MessageRecipients>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: FixedItemsDataSource(
      MapDataSource(
        SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
            UserDataSource(dependencyState.network.serverAPI.users, [
              Role.manager,
              Role.dispatcher,
              Role.driver,
              Role.customer,
              Role.supplier
            ]),
            dependencyState.caches.messageUser)),
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
    formatter: (context, recipients) {
      if (recipients == null) {
        return '';
      }
      if (recipients.user != null) {
        return formatUserSafe(context, recipients.user);
      }
      if (recipients.role != null) {
        return formatRole(context, recipients.role);
      }
      return localizationUtil.allUsers;
    },
    listViewBuilder: (context, recipients) {
      if (recipients.user != null) {
        return SimpleListTile(formatUserSafe(context, recipients.user),
            formatRole(context, recipients.user.role));
      }
      if (recipients.role != null) {
        return SimpleListTile(formatRole(context, recipients.role));
      }
      return SimpleListTile(localizationUtil.allUsers);
    },
    onRefresh: dependencyState.caches.messageUser.clear,
    label: localizationUtil.recipients,
    validator: RequiredValidator(context),
  );
}
