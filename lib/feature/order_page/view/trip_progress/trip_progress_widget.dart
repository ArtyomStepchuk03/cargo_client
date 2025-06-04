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
import 'package:manager_mobile_client/src/logic/external/photo_save_service.dart';
import 'package:manager_mobile_client/src/logic/order/entrance_coordinate_mismatch.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class TripProgressWidget extends StatefulWidget {
  final Order? order;
  final Trip? trip;
  final User? user;
  final Function() onUpdate;

  TripProgressWidget(
      {this.order, this.trip, this.user, required this.onUpdate});

  @override
  State<StatefulWidget> createState() => TripProgressState();
}

class TripProgressState extends State<TripProgressWidget> {
  Map<int, File?> updatedPhotos = {};

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(title: Text(localizationUtil.progress)),
      body: _buildListView(widget.trip?.historyRecords),
    );
  }

  Widget _buildListView(List<TripHistoryRecord?>? records) {
    final configurationLoader =
        DependencyHolder.of(context).network.configurationLoader;
    return ListView.separated(
      itemCount: records!.length,
      itemBuilder: (BuildContext context, int index) => _buildCell(
          context, records[index]!, configurationLoader.configuration!, index),
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
          if (widget.user?.role != Role.customer &&
              record.additionalData != null &&
              record.additionalData?.distance != null)
            _buildSubtitleText(
                '${localizationUtil.distanceInKilometers}: ${record.additionalData!.distance}'),
          if (_shouldShowAttachPhotoButton(record) &&
              (record.photo == null || record.thumbnail == null) &&
              updatedPhotos[index] == null)
            buildAttachPhotoButton(record, index),
          if (record.address != null && record.address!.isNotEmpty)
            _buildSubtitleText(
                '${localizationUtil.address}: ${record.address}'),
          if (widget.user?.role != Role.customer &&
              record.additionalData != null &&
              record.additionalData!.waybillNumber != null &&
              record.additionalData!.waybillNumber!.isNotEmpty)
            _buildSubtitleText(
                '${localizationUtil.waybillNumber}: ${record.additionalData!.waybillNumber}'),
          if (record.comment != null && record.comment!.isNotEmpty)
            _buildSubtitleText(
                '${localizationUtil.comment}: ${record.comment}'),
          if (widget.user?.role != Role.customer &&
              mismatchesWithExpectedCoordinate(
                  record, widget.order!, configuration))
            _buildCoordinateMismatchWidget(context, record),
          if (_shouldShowPhoto(record) || updatedPhotos[index] != null)
            _buildPhotoSection(record, index),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(TripHistoryRecord record, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (updatedPhotos[index] != null)
          Image.file(
            updatedPhotos[index]!,
            width: 80,
            height: 80,
          )
        else
          ThumbnailImage.small(
            context,
            record.thumbnail!.url,
            onTap: () => _showFullPhoto(record),
          ),
        ..._buildPhotoActionButtons(record, index),
      ],
    );
  }

  List<Widget> _buildPhotoActionButtons(TripHistoryRecord record, int index) {
    final buttons = <Widget>[];

    if (widget.user?.role == Role.administrator ||
        widget.user?.role == Role.logistician ||
        widget.user?.role == Role.manager) {
      buttons.addAll([
        IconButton(
          onPressed: () => _pickImage(record, index),
          icon: Icon(Icons.edit),
          tooltip: 'Редактировать фото',
        ),
        IconButton(
          onPressed: () => _showDeletePhotoDialog(context, () async {
            await _deletePhoto(record, index);
          }),
          icon: Icon(Icons.delete_forever, color: Colors.red),
          tooltip: 'Удалить фото',
        ),
      ]);
    }

    if (record.photo != null) {
      buttons.add(
        IconButton(
          onPressed: () => _savePhoto(record),
          icon: Icon(Icons.download),
          tooltip: LocalizationUtil.of(context).save,
        ),
      );
    }

    return buttons;
  }

  bool _shouldShowPhoto(TripHistoryRecord record) {
    if (record.photo == null || record.thumbnail == null) {
      return false;
    }
    if (record.stage == TripStage.loaded) {
      return widget.user?.role != Role.customer;
    }
    if (record.stage == TripStage.unloaded) {
      return true;
    }
    return false;
  }

  bool _shouldShowAttachPhotoButton(TripHistoryRecord record) {
    final bool isRoleAvailable = widget.user?.role == Role.administrator ||
        widget.user?.role == Role.logistician ||
        widget.user?.role == Role.manager;
    final bool isStatusAvailable =
        record.stage == TripStage.loaded || record.stage == TripStage.unloaded;
    return isRoleAvailable && isStatusAvailable;
  }

  Widget _buildDateTimeText(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontSize: _subtitleFontSize));
  }

  Widget _buildStageTitleText(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontSize: _titleFontSize));
  }

  Widget _buildSubtitleText(String text) {
    return Text(text,
        style: TextStyle(color: Colors.black38, fontSize: _subtitleFontSize));
  }

  Widget buildAttachPhotoButton(TripHistoryRecord record, int index) {
    final localizationUtil = LocalizationUtil.of(context);
    return ElevatedButton(
      onPressed: () => _pickImage(record, index),
      style: ButtonStyle(
          backgroundColor:
              WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)),
      child: Text(
        localizationUtil.attachPhoto,
      ),
    );
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
              .titleMedium
              ?.copyWith(color: Colors.white, fontSize: 14),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        deleteIconColor: Colors.white,
        onDeleted: () => _ignoreCoordinateMismatch(record),
      ),
    );
  }

  Future<void> _showDeletePhotoDialog(
      BuildContext context, VoidCallback onConfirmDelete) async {
    final localizationUtil = LocalizationUtil.of(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizationUtil.deleteImageQuestion),
          content: Text(localizationUtil.deleteImageAccept),
          actions: <Widget>[
            TextButton(
              child: Text(localizationUtil.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                localizationUtil.delete,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmDelete();
              },
            ),
          ],
        );
      },
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
            builder: (context) => FullImageWidget(record.photo!.url,
                title: formatTripStage(context, record.stage)),
            fullscreenDialog: true));
  }

  void _pickImage(TripHistoryRecord record, int index) async {
    final newFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 1600,
        maxWidth: 1600,
        imageQuality: 80);
    if (newFile == null) {
      return;
    }

    try {
      String base64Image = base64Encode(await newFile.readAsBytes());
      final serverAPI = DependencyHolder.of(context).network.serverAPI.trips;
      await serverAPI.updatePhoto(record, base64Image);
      await widget.onUpdate();
      setState(() {
        updatedPhotos[index] = File(newFile.path);
      });
    } catch (e) {
      showDefaultErrorDialog(context);
    }
  }

  Future<void> _deletePhoto(TripHistoryRecord record, int index) async {
    try {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.trips;
      await serverAPI.deletePhoto(record);
      setState(() {
        record.thumbnail = null;
        record.photo = null;
        updatedPhotos[index] = null;
      });
    } catch (e) {
      showDefaultErrorDialog(context);
    }
  }

  void _savePhoto(TripHistoryRecord record) async {
    final localizationUtil = LocalizationUtil.of(context);

    if (record.photo?.url == null) {
      PhotoSaveService.showSaveResultSnackbar(
        context,
        PhotoSaveResult.error(localizationUtil.photoSaveError),
        '',
        '',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text(localizationUtil.downloadingPhoto)),
          ],
        ),
      ),
    );

    try {
      final fileName = _generatePhotoFileName(record);

      final result = await PhotoSaveService.savePhotoToGallery(
        record.photo!.url,
        fileName,
      );

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        PhotoSaveService.showSaveResultSnackbar(
          context,
          result,
          localizationUtil.photoSavedToGallery,
          localizationUtil.open,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        PhotoSaveService.showSaveResultSnackbar(
          context,
          PhotoSaveResult.error(
              '${localizationUtil.photoSaveError}: ${e.toString()}'),
          '',
          '',
        );
      }
    }
  }

  String _generatePhotoFileName(TripHistoryRecord record) {
    final orderNumber = widget.order?.number ?? 0;
    final stageName = _getStageFileName(record.stage);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return 'order_${orderNumber}_${stageName}_$timestamp';
  }

  String _getStageFileName(TripStage? stage) {
    switch (stage) {
      case TripStage.loaded:
        return 'loaded';
      case TripStage.unloaded:
        return 'unloaded';
      default:
        return 'unknown';
    }
  }

  static const _titleFontSize = 16.0;
  static const _subtitleFontSize = 13.0;
}
