import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/form/contact/phone_number_dial_field.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/order_page/view/trip_progress/trip_progress_widget.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/format/format.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class OrderDetailsProgressBody extends StatelessWidget {
  final Order order;
  final User user;
  final RefreshCallback onRefresh;
  final bool insetForFloatingActionButton;

  OrderDetailsProgressBody(
      {this.order,
      this.user,
      this.onRefresh,
      this.insetForFloatingActionButton = false});

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
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
          Icons.local_shipping,
          _buildNoneditableTextField(
              context,
              formatVehicleModelSafe(
                  context, offer.transportUnit?.vehicle?.model),
              localizationUtil.vehicleFullName)),
      buildFormRow(
          null,
          _buildNoneditableTextField(
              context,
              textOrEmpty(offer.transportUnit?.vehicle?.number),
              localizationUtil.stateNumber)),
      if (offer.transportUnit.trailer != null)
        buildFormRow(
            null,
            _buildNoneditableTextField(
                context,
                textOrEmpty(offer.transportUnit?.trailer?.number),
                localizationUtil.trailerNumber)),
      buildFormRow(
          null,
          _buildNoneditableTextField(
              context,
              short.formatDriverSafe(context, offer.transportUnit?.driver),
              localizationUtil.personName)),
      if (user.canAccessDriverPhoneNumber())
        buildFormRow(
            null,
            PhoneNumberDialField(
                phoneNumber: offer.transportUnit?.driver?.phoneNumber,
                label: localizationUtil.phoneNumber)),
      if (Role.isManagerOrHigher(user.role) ||
          Role.isDispatcherOrHigher(user.role))
        buildFormRow(
            null,
            _buildNoneditableTextField(
                context,
                short.formatCarrierSafe(
                    context, offer.transportUnit?.driver?.carrier),
                localizationUtil.carrier)),
      buildFormRow(
          null,
          _buildNoneditableTextField(context, formatOfferStatus(context, offer),
              localizationUtil.orderStage)),
      if (offer?.trip?.historyRecords != null &&
          offer.trip.historyRecords.length != 0)
        buildFormRow(
            null,
            buildButton(context,
                child: Text(localizationUtil.details),
                onPressed: () => _showTripProgress(context, offer))),
    ]);
  }

  Widget _buildNoneditableTextField(
      BuildContext context, String text, String label) {
    return buildCustomNoneditableTextField(
        context: context, label: label, text: text, enabled: false);
  }

  void _showTripProgress(BuildContext context, Offer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => TripProgressWidget(
            order: order, trip: offer.trip, user: user, onUpdate: onRefresh),
      ),
    );
  }
}
