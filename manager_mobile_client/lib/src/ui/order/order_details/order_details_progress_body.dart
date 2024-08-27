import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/common/button.dart';
import 'package:manager_mobile_client/src/ui/common/floating_action_button.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/form/contact/phone_number_dial_field.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/format.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/format/stage.dart';
import 'package:manager_mobile_client/src/ui/order/trip_progress/trip_progress_widget.dart';
import 'order_details_strings.dart' as strings;

class OrderDetailsProgressBody extends StatelessWidget {
  final Order order;
  final User user;
  final RefreshCallback onRefresh;
  final bool insetForFloatingActionButton;

  OrderDetailsProgressBody({this.order, this.user, this.onRefresh, this.insetForFloatingActionButton = false});

  @override
  Widget build(BuildContext context) {
    final groups = <Widget>[];
    if (order.offers != null) {
      for (final offer in order.offers) {
        groups.add(_buildOfferGroup(context, offer));
      }
    }
    groups.add(buildFloatingActionButtonSpacer(insetForFloatingActionButton));
    return buildRefreshableForm(onRefresh: onRefresh, children: groups);
  }

  Widget _buildOfferGroup(BuildContext context, Offer offer) {
    return buildFormGroup([
      buildFormRow(Icons.local_shipping,
        _buildNoneditableTextField(context, formatVehicleModelSafe(offer.transportUnit?.vehicle?.model), strings.vehicleFullName)
      ),
      buildFormRow(null,
        _buildNoneditableTextField(context, textOrEmpty(offer.transportUnit?.vehicle?.number), strings.stateNumber)
      ),
      if (offer.transportUnit.trailer != null)
        buildFormRow(null,
          _buildNoneditableTextField(context, textOrEmpty(offer.transportUnit?.trailer?.number), strings.trailerNumber)
        ),
      buildFormRow(null,
        _buildNoneditableTextField(context, short.formatDriverSafe(offer.transportUnit?.driver), strings.personName)
      ),
      if (user.canAccessDriverPhoneNumber())
        buildFormRow(null,
          PhoneNumberDialField(phoneNumber: offer.transportUnit?.driver?.phoneNumber, label: strings.phoneNumber)
        ),
      if (Role.isManagerOrHigher(user.role) || Role.isDispatcherOrHigher(user.role))
        buildFormRow(null,
          _buildNoneditableTextField(context, short.formatCarrierSafe(offer.transportUnit?.driver?.carrier), strings.carrier)
        ),
      buildFormRow(null,
        _buildNoneditableTextField(context, formatOfferStatus(offer), strings.stage)
      ),
      if (offer?.trip?.historyRecords != null && offer.trip.historyRecords.length != 0)
        buildFormRow(null,
          buildButton(context, child: Text(strings.details), onPressed: () => _showTripProgress(context, offer))
        ),
    ]);
  }

  Widget _buildNoneditableTextField(BuildContext context, String text, String label) {
    return buildCustomNoneditableTextField(context: context, label: label, text: text, enabled: false);
  }

  void _showTripProgress(BuildContext context, Offer offer) {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => TripProgressWidget(order: order, trip: offer.trip, user: user),
    ));
  }
}
