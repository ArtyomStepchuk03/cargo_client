import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/full_image_widget.dart';
import 'package:manager_mobile_client/common/image.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/external/image_picker.dart';
import 'package:manager_mobile_client/src/logic/order/entrance_coordinate_mismatch.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class TripProgressWidget extends StatefulWidget {
  final Order order;
  final Trip trip;
  final User user;
  final Function() onUpdate;

  TripProgressWidget({this.order, this.trip, this.user, this.onUpdate});

  @override
  State<StatefulWidget> createState() => TripProgressState();
}

class TripProgressState extends State<TripProgressWidget> {
  Map<int, File> updatedPhotos = {};

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(title: Text(localizationUtil.progress)),
      body: _buildListView(widget.trip.historyRecords),
    );
  }

  Widget _buildListView(List<TripHistoryRecord> records) {
    final configurationLoader =
        DependencyHolder.of(context).network.configurationLoader;
    return ListView.separated(
      itemCount: records.length,
      itemBuilder: (BuildContext context, int index) => _buildCell(
          context, records[index], configurationLoader.configuration, index),
      separatorBuilder: (BuildContext context, int index) =>
          Divider(thickness: 1, height: 1),
    );
  }

  Widget _buildCell(BuildContext context, TripHistoryRecord record,
      Configuration configuration, index) {
    final localizationUtil = LocalizationUtil.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeText(context, formatDateSafe(record.date)),
          _buildStageTitleText(context, formatTripStage(context, record.stage)),
          if (record.tonnage != null)
            _buildSubtitleText(
                '${localizationUtil.actualTonnage}: ${record.tonnage}'),
          if (widget.user.role != Role.customer &&
              record.additionalData != null &&
              record.additionalData.distance != null)
            _buildSubtitleText(
                '${localizationUtil.distanceInKilometers}: ${record.additionalData.distance}'),
          if (record.address != null && record.address.isNotEmpty)
            _buildSubtitleText(
                '${localizationUtil.address}: ${record.address}'),
          if (widget.user.role != Role.customer &&
              record.additionalData != null &&
              record.additionalData.waybillNumber != null &&
              record.additionalData.waybillNumber.isNotEmpty)
            _buildSubtitleText(
                '${localizationUtil.waybillNumber}: ${record.additionalData.waybillNumber}'),
          if (record.comment != null && record.comment.isNotEmpty)
            _buildSubtitleText(
                '${localizationUtil.comment}: ${record.comment}'),
          if (widget.user.role != Role.customer &&
              mismatchesWithExpectedCoordinate(
                  record, widget.order, configuration))
            _buildCoordinateMismatchWidget(context, record),
          if (_shouldShowPhoto(record))
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (updatedPhotos[index] != null)
                  Image.file(
                    updatedPhotos[index],
                    width: 80,
                    height: 80,
                  )
                else
                  ThumbnailImage.small(
                    context,
                    record.thumbnail.url,
                    onTap: () => _showFullPhoto(record),
                  ),
                IconButton(
                    onPressed: () async {
                      final newFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxHeight: 1600,
                          maxWidth: 1600,
                          imageQuality: 80);
                      if (newFile == null) {
                        return null;
                      }
                      String base64Image =
                          base64Encode(await newFile.readAsBytes());

                      final serverAPI =
                          DependencyHolder.of(context).network.serverAPI.trips;
                      await serverAPI.updatePhoto(record, base64Image);
                      await widget.onUpdate();
                      setState(() {
                        updatedPhotos[index] = File(newFile.path);
                      });
                    },
                    icon: Icon(Icons.edit)),
                IconButton(
                  onPressed: () async {
                    final serverAPI =
                        DependencyHolder.of(context).network.serverAPI.trips;
                    await serverAPI.deletePhoto(record);
                    setState(() => record.thumbnail = null);
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  bool _shouldShowPhoto(TripHistoryRecord record) {
    if (record.photo == null || record.thumbnail == null) {
      return false;
    }
    if (record.stage == TripStage.loaded) {
      return widget.user.role != Role.customer;
    }
    if (record.stage == TripStage.unloaded) {
      return true;
    }
    return false;
  }

  Widget _buildDateTimeText(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(fontSize: _subtitleFontSize));
  }

  Widget _buildStageTitleText(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(fontSize: _titleFontSize));
  }

  Widget _buildSubtitleText(String text) {
    return Text(text,
        style: TextStyle(color: Colors.black38, fontSize: _subtitleFontSize));
  }

  Widget _buildCoordinateMismatchWidget(
      BuildContext context, TripHistoryRecord record) {
    final localizationUtil = LocalizationUtil.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Chip(
        backgroundColor: Colors.redAccent,
        label: Text(
          localizationUtil.coordinateMismatch,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white, fontSize: 14),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        deleteIconColor: Colors.white,
        onDeleted: () => _ignoreCoordinateMismatch(record),
      ),
    );
  }

  void _ignoreCoordinateMismatch(TripHistoryRecord record) async {
    showDefaultActivityDialog(context);
    final serverAPI = DependencyHolder.of(context).network.serverAPI.trips;
    try {
      await serverAPI.ignoreCoordinateMismatch(record);
      Navigator.pop(context);
      setState(() {});
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  void _showFullPhoto(TripHistoryRecord record) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FullImageWidget(record.photo.url,
                title: formatTripStage(context, record.stage)),
            fullscreenDialog: true));
  }

  static const _titleFontSize = 16.0;
  static const _subtitleFontSize = 13.0;
}
