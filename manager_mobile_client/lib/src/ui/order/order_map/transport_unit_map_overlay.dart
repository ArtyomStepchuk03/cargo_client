import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'package:manager_mobile_client/src/ui/utility/image.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/common_format.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/format.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'order_map_strings.dart' as strings;

class TransportUnitMapOverlay extends StatefulWidget {
  final TransportUnit transportUnit;

  TransportUnitMapOverlay(this.transportUnit);

  @override
  State<StatefulWidget> createState() => TransportUnitMapOverlayState();
}

class TransportUnitMapOverlayState extends State<TransportUnitMapOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10, right: 10,
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
    return _buildContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(short.formatDriverSafe(widget.transportUnit.driver)),
          Text(strings.vehicleModel(formatVehicleModelSafe(widget.transportUnit.vehicle?.model))),
          Text(strings.stateNumber(textOrEmpty(widget.transportUnit.vehicle?.number))),
          Text(strings.speed(formatSpeedSafe(widget.transportUnit.speed))),
          Text(strings.lastVisit(formatDateSafe(widget.transportUnit.lastVisitDate))),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return _buildContainer(
      width: 50, height: 50,
      child: ImageUtility.named('map/map_truck'),
    );
  }

  Widget _buildContainer({double width, double height, Widget child}) {
    return Container(
      width: width, height: height,
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
