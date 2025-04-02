import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'package:manager_mobile_client/util/format/common_format.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/format.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/image.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class TransportUnitMapOverlay extends StatefulWidget {
  final TransportUnit? transportUnit;

  TransportUnitMapOverlay(this.transportUnit);

  @override
  State<StatefulWidget> createState() => TransportUnitMapOverlayState();
}

class TransportUnitMapOverlayState extends State<TransportUnitMapOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: InkWell(
        child: _buildContent(),
        onTap: _toggle,
      ),
    );
  }

  var _expanded = false;

  Widget _buildContent() {
    if (_expanded) {
      return _buildExpanded();
    } else {
      return _buildIcon();
    }
  }

  Widget _buildExpanded() {
    final localizationUtil = LocalizationUtil.of(context);
    return _buildContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(short.formatDriverSafe(context, widget.transportUnit?.driver)),
          Text(
              '${localizationUtil.vehicleFullName}: ${formatVehicleModelSafe(context, widget.transportUnit?.vehicle?.model)}'),
          Text(
              '${localizationUtil.stateNumber}: ${textOrEmpty(widget.transportUnit?.vehicle?.number)}'),
          Text(
              '${localizationUtil.speed}: ${formatSpeedSafe(context, widget.transportUnit?.speed)}'),
          Text(
              '${localizationUtil.lastVisit}: ${formatDateSafe(widget.transportUnit?.lastVisitDate)}'),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return _buildContainer(
      width: 50,
      height: 50,
      child: ImageUtility.named('map/map_truck'),
    );
  }

  Widget _buildContainer({double? width, double? height, Widget? child}) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(3.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }
}
