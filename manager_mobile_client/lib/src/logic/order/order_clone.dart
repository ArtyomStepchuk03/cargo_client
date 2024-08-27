import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

Order cloneOrder(Order other, User user) {
  var order = Order();
  order.type = other.type;

  order.articleShape = other.articleShape;
  order.articleBrand = other.articleBrand;
  order.tonnage = other.tonnage;
  order.undistributedTonnage = other.tonnage;
  order.distributedTonnage = 0;
  order.unfinishedTonnage = other.tonnage;
  order.finishedTonnage = 0;

  if (user.role != Role.customer) {
    order.intermediary = other.intermediary;
    order.supplier = other.supplier;
    order.loadingPoint = other.loadingPoint;
    order.loadingEntrance = other.loadingEntrance;
  }

  order.customer = other.customer;
  order.unloadingPoint = other.unloadingPoint;
  order.unloadingEntrance = other.unloadingEntrance;

  if (user.role == Role.customer) {
    order.salePriceType = user.customer.priceType;
  } else {
    order.saleTariff = other.saleTariff;
    order.salePriceType = other.salePriceType;
    order.deliveryTariff = other.deliveryTariff;
    order.deliveryPriceType = other.deliveryPriceType;
  }

  order.comment = other.comment;
  if (user.role != Role.customer) {
    order.inactivityTimeInterval = other.inactivityTimeInterval;
  }

  final now = DateTime.now();
  final tomorrow = now.add(Duration(days: 1));
  if (user.role != Role.customer) {
    order.loadingDate = _changeDatePreservingTime(other.loadingDate, now);
  }
  order.unloadingBeginDate = _changeDatePreservingTime(other.unloadingBeginDate, tomorrow);
  order.unloadingEndDate = _changeDatePreservingTime(other.unloadingEndDate, tomorrow);

  return order;
}

Order cloneReservation(Order other) {
  var reservation = Order();
  reservation.type = other.type;

  reservation.articleShape = other.articleShape;
  reservation.articleBrand = other.articleBrand;
  reservation.tonnage = other.tonnage;
  reservation.undistributedTonnage = other.tonnage;
  reservation.distributedTonnage = 0;
  reservation.unfinishedTonnage = other.tonnage;
  reservation.finishedTonnage = 0;

  reservation.supplier = other.supplier;
  reservation.loadingPoint = other.loadingPoint;
  reservation.customer = other.customer;
  reservation.unloadingPoint = other.unloadingPoint;

  reservation.comment = other.comment;

  reservation.unloadingBeginDate = other.unloadingBeginDate;

  return reservation;
}

DateTime _changeDatePreservingTime(DateTime source, DateTime newDate) {
  if (source == null) {
    return null;
  }
  final localSource = source.toLocal();
  final localNewDate = newDate.toLocal();
  return DateTime(localNewDate.year, localNewDate.month, localNewDate.day, localSource.hour, localSource.minute);
}
