import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'short_format.dart';
import 'user.dart';

class OrderStatusFormatFlags {
  final bool carrier;
  final bool transportUnit;
  final bool inWork;
  const OrderStatusFormatFlags(
      {this.carrier = false, this.transportUnit = false, this.inWork = false});
  const OrderStatusFormatFlags.all(bool long)
      : this(carrier: long, transportUnit: long, inWork: long);
  const OrderStatusFormatFlags.short() : this.all(false);
  const OrderStatusFormatFlags.long() : this.all(true);
}

String formatOrderStatus(BuildContext context, Order order, User user,
    {bool reservation = false,
    OrderStatusFormatFlags flags = const OrderStatusFormatFlags.short()}) {
  final localizationUtil = LocalizationUtil.of(context);
  if (order.offers != null && order.offers.isNotEmpty) {
    final offer = order.offers[0];
    if (offer.trip != null || offer.declined) {
      return _formatStatusForTransportUnit(
          context, formatOfferStatus(context, offer), offer.transportUnit,
          long: flags.transportUnit);
    }
    return _formatStatusForTransportUnit(
        context, localizationUtil.orderSentToDriver, offer.transportUnit,
        long: flags.transportUnit);
  }
  if (user.role == Role.customer) {
    return localizationUtil.underProcess;
  }
  if (order.carrierOffers != null && order.carrierOffers.isNotEmpty) {
    final carrierOffer = order.carrierOffers[0];
    if (user.role == Role.dispatcher && carrierOffer.carrier == user.carrier) {
      if (carrierOffer.accepted == null || !carrierOffer.accepted) {
        return _formatStatusForCarrier(
            context,
            formatCarrierOfferStatus(context, carrierOffer, myOffer: true),
            carrierOffer.carrier);
      }
    } else {
      if (carrierOffer.accepted != null) {
        return _formatStatusForCarrier(
            context,
            formatCarrierOfferStatus(context, carrierOffer, myOffer: false),
            carrierOffer.carrier,
            long: flags.carrier);
      }
      if (reservation) {
        return _formatStatusForCarrier(context,
            localizationUtil.awaitingConfirmation, carrierOffer.carrier,
            long: flags.carrier);
      }
      return _formatStatusForCarrier(
          context, localizationUtil.orderSentToCarrier, carrierOffer.carrier,
          long: flags.carrier);
    }
  }
  if (user.role != Role.dispatcher &&
      order.author != null &&
      order.author.role == Role.dispatcher) {
    return _formatStatusForCarrier(
        context, localizationUtil.orderCreatedByCarrier, order.author.carrier,
        long: flags.carrier);
  }
  if (order.status == OrderStatus.ready) {
    if (reservation) {
      return localizationUtil.reservationProcessed;
    }
    return localizationUtil.orderUndistributed;
  }
  if (order.status == OrderStatus.inWork) {
    final historyRecord = order.getTakenIntoWorkHistoryRecord();
    return _formatStatusForUser(
        context, localizationUtil.inWork, historyRecord?.user,
        long: flags.inWork);
  }
  if (order.status == OrderStatus.customerRequest && reservation) {
    return localizationUtil.customerRequest;
  }
  return localizationUtil.reservationNotProcessed;
}

String formatCarrierOfferStatus(BuildContext context, CarrierOffer carrierOffer,
    {bool myOffer}) {
  final localizationUtil = LocalizationUtil.of(context);
  if (carrierOffer.accepted != null) {
    if (carrierOffer.accepted) {
      return myOffer
          ? localizationUtil.orderAcceptedByYou
          : localizationUtil.orderAcceptedByCarrier;
    } else {
      return myOffer
          ? localizationUtil.orderDeclinedByYou
          : localizationUtil.orderDeclinedByCarrier;
    }
  }
  return myOffer
      ? localizationUtil.orderUnacceptedByYou
      : localizationUtil.orderUnacceptedByCarrier;
}

String formatOfferStatus(BuildContext context, Offer offer) {
  final localizationUtil = LocalizationUtil.of(context);
  if (offer.trip != null) {
    return formatTripStatus(context, offer.trip);
  }
  if (offer.declined) {
    return localizationUtil.offerDeclined;
  }
  return localizationUtil.offerUnaccepted;
}

String formatTripStatus(BuildContext context, Trip trip) {
  final localizationUtil = LocalizationUtil.of(context);
  if (trip.stage != null) {
    return formatTripStage(context, trip.stage);
  }
  return localizationUtil.offerAccepted;
}

String formatTripStage(BuildContext context, TripStage stage) {
  final localizationUtil = LocalizationUtil.of(context);
  switch (stage) {
    case TripStage.drivingForLoading:
      return localizationUtil.drivingForLoading;
    case TripStage.inLoadingPoint:
      return localizationUtil.inLoadingPoint;
    case TripStage.loaded:
      return localizationUtil.loaded;
    case TripStage.drivingForUnloading:
      return localizationUtil.drivingForUnloading;
    case TripStage.inUnloadingPoint:
      return localizationUtil.inUnloadingPoint;
    case TripStage.unloaded:
      return localizationUtil.unloaded;
    default:
      return localizationUtil.unknownStatus;
  }
}

String _formatStatusForUser(BuildContext context, String status, User user,
    {bool long = false}) {
  return _formatStatus(status, formatUserSafe(context, user), long: long);
}

String _formatStatusForCarrier(
    BuildContext context, String status, Carrier carrier,
    {bool long = false}) {
  return _formatStatus(status, formatCarrierSafe(context, carrier), long: long);
}

String _formatStatusForTransportUnit(
    BuildContext context, String status, TransportUnit transportUnit,
    {bool long = false}) {
  return _formatStatus(status, formatDriverSafe(context, transportUnit?.driver),
      long: long);
}

String _formatStatus(String status, String subject, {bool long = false}) {
  if (long) {
    return '$status: $subject';
  } else {
    return status;
  }
}
