import 'package:flutter/widgets.dart' show VoidCallback;
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_subscription.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_api/trip_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/offer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';

class OrderProgressNotifier {
  final OrderServerAPI orderServerAPI;
  final OfferServerAPI offerServerAPI;
  final TripServerAPI tripServerAPI;

  OrderProgressNotifier(this.orderServerAPI, this.offerServerAPI, this.tripServerAPI) : _offerSubscriptions = {}, _tripSubscriptions = {};

  void subscribe(Order order) {
    _setOrderSubscription(order);
    _updateOfferSubscriptions(order);
    _updateTripSubscriptions(order);
  }

  void unsubscribe() {
    orderServerAPI.unsubscribe(_orderSubscription);
    for (final subscription in _offerSubscriptions.values) offerServerAPI.unsubscribe(subscription);
    for (final subscription in _tripSubscriptions.values) tripServerAPI.unsubscribe(subscription);
    _orderSubscription = null;
    _offerSubscriptions.clear();
    _tripSubscriptions.clear();
  }

  VoidCallback onProgressChange;

  parse.LiveQuerySubscription<Order> _orderSubscription;
  Map<Offer, parse.LiveQuerySubscription<Offer>> _offerSubscriptions;
  Map<Trip, parse.LiveQuerySubscription<Trip>> _tripSubscriptions;

  void _setOrderSubscription(Order order) {
    _orderSubscription = orderServerAPI.subscribeToChanges(order);
    _orderSubscription.onUpdate = (changedOrder) async {
      await orderServerAPI.fetchProgress(order);
      _updateOfferSubscriptions(order);
      _updateTripSubscriptions(order);
      if (onProgressChange != null) onProgressChange();
    };
  }

  void _updateOfferSubscriptions(Order order) {
    var offersToSubscribe = order.offers?.toSet() ?? <Offer>{};
    var offersToUnsubscribe = <Offer>{};
    for (final entry in _offerSubscriptions.entries) {
      if (offersToSubscribe.contains(entry.key)) {
        offersToSubscribe.remove(entry.key);
      } else {
        offersToUnsubscribe.add(entry.key);
      }
    }
    for (final offer in offersToUnsubscribe) {
      offerServerAPI.unsubscribe(_offerSubscriptions[offer]);
      _offerSubscriptions.remove(offer);
    }
    for (final offer in offersToSubscribe) {
      final subscription = offerServerAPI.subscribeToChanges(offer);
      _offerSubscriptions[offer] = subscription;
      subscription.onUpdate = (changedOffer) async {
        await orderServerAPI.fetchProgress(order);
        _updateTripSubscriptions(order);
        if (onProgressChange != null) onProgressChange();
      };
    }
  }

  void _updateTripSubscriptions(Order order) {
    var tripsToSubscribe = order.offers?.map((offer) => offer.trip)?.where((trip) => trip != null)?.toSet() ?? <Trip>{};
    var tripsToUnsubscribe = <Trip>{};
    for (final entry in _tripSubscriptions.entries) {
      if (tripsToSubscribe.contains(entry.key)) {
        tripsToSubscribe.remove(entry.key);
      } else {
        tripsToUnsubscribe.add(entry.key);
      }
    }
    for (final trip in tripsToUnsubscribe) {
      tripServerAPI.unsubscribe(_tripSubscriptions[trip]);
      _tripSubscriptions.remove(trip);
    }
    for (final trip in tripsToSubscribe) {
      final subscription = tripServerAPI.subscribeToChanges(trip);
      _tripSubscriptions[trip] = subscription;
      subscription.onUpdate = (changedTrip) async {
        if (onProgressChange != null) onProgressChange();
      };
    }
  }
}
