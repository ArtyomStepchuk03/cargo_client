import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';

bool hasLoadingEntranceCoordinateMismatch(
    Order order, Configuration configuration) {
  return _hasEntranceCoordinateMismatch(order.loadingEntrance,
      _getHistoryRecord(order, TripStage.loaded), configuration);
}

bool hasUnloadingEntranceCoordinateMismatch(
    Order order, Configuration configuration) {
  return _hasEntranceCoordinateMismatch(order.unloadingEntrance,
      _getHistoryRecord(order, TripStage.unloaded), configuration);
}

bool mismatchesWithExpectedCoordinate(
    TripHistoryRecord historyRecord, Order order, Configuration configuration) {
  return _hasEntranceCoordinateMismatch(
      _getEntrance(order, historyRecord.stage), historyRecord, configuration);
}

bool hasAnyEntranceCoordinateMismatch(
    Order order, Configuration configuration) {
  return hasLoadingEntranceCoordinateMismatch(order, configuration) ||
      hasUnloadingEntranceCoordinateMismatch(order, configuration);
}

bool _hasEntranceCoordinateMismatch(Entrance entrance,
    TripHistoryRecord historyRecord, Configuration configuration) {
  if (configuration?.maximumEntranceDeviation == null) {
    return false;
  }

  if (entrance == null || historyRecord == null) {
    return false;
  }

  if (historyRecord.ignoreWrongCoordinate) {
    return false;
  }

  final expectedCoordinate = entrance.coordinate;
  final actualCoordinate = historyRecord.coordinate;

  if (expectedCoordinate == null || actualCoordinate == null) {
    return false;
  }

  final deviation = getDistance(actualCoordinate, expectedCoordinate);
  return deviation > configuration.maximumEntranceDeviation;
}

TripHistoryRecord _getHistoryRecord(Order order, TripStage stage) {
  final offer = order.getAcceptedOffer();

  if (offer == null) {
    return null;
  }

  return offer.trip.getHistoryRecord(stage);
}

Entrance _getEntrance(Order order, TripStage stage) {
  switch (stage) {
    case TripStage.loaded:
      return order.loadingEntrance;
    case TripStage.unloaded:
      return order.unloadingEntrance;
    default:
      return null;
  }
}
