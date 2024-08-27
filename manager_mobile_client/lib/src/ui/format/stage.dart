import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'short_format.dart';
import 'user.dart';
import 'format_strings.dart' as strings;

class OrderStatusFormatFlags {
  final bool carrier;
  final bool transportUnit;
  final bool inWork;
  const OrderStatusFormatFlags({this.carrier = false, this.transportUnit = false, this.inWork = false});
  const OrderStatusFormatFlags.all(bool long) : this(carrier: long, transportUnit: long, inWork: long);
  const OrderStatusFormatFlags.short() : this.all(false);
  const OrderStatusFormatFlags.long() : this.all(true);
}

String formatOrderStatus(Order order, User user, {bool reservation = false, OrderStatusFormatFlags flags = const OrderStatusFormatFlags.short()}) {
  if (order.offers != null && order.offers.isNotEmpty) {
    final offer = order.offers[0];
    if (offer.trip != null || offer.declined) {
      return _formatStatusForTransportUnit(formatOfferStatus(offer), offer.transportUnit, long: flags.transportUnit);
    }
    return _formatStatusForTransportUnit(strings.orderSentToDriver, offer.transportUnit, long: flags.transportUnit);
  }
  if (user.role == Role.customer) {
    return strings.underProcess;
  }
  if (order.carrierOffers != null && order.carrierOffers.isNotEmpty) {
    final carrierOffer = order.carrierOffers[0];
    if (user.role == Role.dispatcher && carrierOffer.carrier == user.carrier) {
      if (carrierOffer.accepted == null || !carrierOffer.accepted) {
        return _formatStatusForCarrier(formatCarrierOfferStatus(carrierOffer, myOffer: true), carrierOffer.carrier);
      }
    } else {
      if (carrierOffer.accepted != null) {
        return _formatStatusForCarrier(formatCarrierOfferStatus(carrierOffer, myOffer: false), carrierOffer.carrier, long: flags.carrier);
      }
      if (reservation) {
        return _formatStatusForCarrier(strings.awaitingConfirmation, carrierOffer.carrier, long: flags.carrier);
      }
      return _formatStatusForCarrier(strings.orderSentToCarrier, carrierOffer.carrier, long: flags.carrier);
    }
  }
  if (user.role != Role.dispatcher && order.author != null && order.author.role == Role.dispatcher) {
    return _formatStatusForCarrier(strings.orderCreatedByCarrier, order.author.carrier, long: flags.carrier);
  }
  if (order.status == OrderStatus.ready) {
    if (reservation) {
      return strings.reservationProcessed;
    }
    return strings.orderUndistributed;
  }
  if (order.status == OrderStatus.inWork) {
    final historyRecord = order.getTakenIntoWorkHistoryRecord();
    return _formatStatusForUser(strings.inWork, historyRecord?.user, long: flags.inWork);
  }
  if (order.status == OrderStatus.customerRequest && reservation) {
    return strings.customerRequest;
  }
  return strings.reservationNotProcessed;
}

String formatCarrierOfferStatus(CarrierOffer carrierOffer, {bool myOffer}) {
  if (carrierOffer.accepted != null) {
    if (carrierOffer.accepted) {
      return myOffer ? strings.orderAcceptedByYou : strings.orderAcceptedByCarrier;
    } else {
      return myOffer ? strings.orderDeclinedByYou : strings.orderDeclinedByCarrier;
    }
  }
  return myOffer ? strings.orderUnacceptedByYou : strings.orderUnacceptedByCarrier;
}

String formatOfferStatus(Offer offer) {
  if (offer.trip != null) {
    return formatTripStatus(offer.trip);
  }
  if (offer.declined) {
    return strings.offerDeclined;
  }
  return strings.offerUnaccepted;
}

String formatTripStatus(Trip trip) {
  if (trip.stage != null) {
    return formatTripStage(trip.stage);
  }
  return strings.offerAccepted;
}

String formatTripStage(TripStage stage) {
  switch (stage) {
    case TripStage.drivingForLoading: return strings.drivingForLoading;
    case TripStage.inLoadingPoint: return strings.inLoadingPoint;
    case TripStage.loaded: return strings.loaded;
    case TripStage.drivingForUnloading: return strings.drivingForUnloading;
    case TripStage.inUnloadingPoint: return strings.inUnloadingPoint;
    case TripStage.unloaded: return strings.unloaded;
    default: return strings.unknownStatus;
  }
}

String _formatStatusForUser(String status, User user, {bool long = false}) {
  return _formatStatus(status, formatUserSafe(user), long: long);
}

String _formatStatusForCarrier(String status, Carrier carrier, {bool long = false}) {
  return _formatStatus(status, formatCarrierSafe(carrier), long: long);
}

String _formatStatusForTransportUnit(String status, TransportUnit transportUnit, {bool long = false}) {
  return _formatStatus(status, formatDriverSafe(transportUnit?.driver), long: long);
}

String _formatStatus(String status, String subject, {bool long = false}) {
  if (long) {
    return '$status: $subject';
  } else {
    return status;
  }
}
