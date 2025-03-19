import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/message.dart';
import 'package:manager_mobile_client/src/logic/core/intersperse.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import '../widget/message_details_widget.dart';

class MessageListBody extends StatefulWidget {
  final bool insetForFloatingActionButton;

  MessageListBody({Key? key, this.insetForFloatingActionButton = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MessageListBodyState();
}

class MessageListBodyState extends State<MessageListBody> {
  void removeMessage(Message? message) =>
      _listViewKey.currentState?.removeItem(message);
  void setNeedReload() => _listViewKey.currentState?.setNeedReload();

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      key: _listViewKey,
      dataSource: SkipPagedDataSourceAdapter(
          DependencyHolder.of(context)!.network.serverAPI.messages),
      builder: _buildCell,
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
      insetForFloatingActionButton: widget.insetForFloatingActionButton,
    );
  }

  final _listViewKey = GlobalKey<LoadingListViewState>();

  Widget _buildCell(BuildContext context, Message? message) {
    final localizationUtil = LocalizationUtil.of(context);
    return InkWell(
      onTap: () => _showDetails(context, message),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(textOr(message?.title, placeholder: localizationUtil.noTitle),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text(textOrEmpty(message?.body)),
            Text(formatDateSafe(message?.date),
                style: TextStyle(color: Colors.grey)),
          ].intersperse(SizedBox(height: 6)).toList(),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Message? message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            MessageDetailsWidget(message: message, listBodyState: this),
      ),
    );
  }
}
