import 'dart:convert';
import 'dart:io';
import 'dart:ui' show hashValues;

import 'package:manager_mobile_client/src/logic/coder/change_encoder.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_manager.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
export 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

export 'server_error.dart';

enum OrderProgress { notFullyDistributed, notFullyFinished, fullyFinished }

enum OrderOfferingStatus { none, carriersOnly, drivers }

enum OrderSortType {
  byDefault,
  byUnloadingDate,
}

enum OrderSortDirection {
  ascending,
  descending,
}

class OrderFilter {
  final bool deleted;
  final OrderProgress progress;
  final OrderOfferingStatus offeringStatus;

  OrderFilter.deleted()
      : deleted = true,
        progress = null,
        offeringStatus = null;

  OrderFilter.allExceptDeleted()
      : deleted = false,
        progress = null,
        offeringStatus = null;

  OrderFilter.notFullyDistributed([this.offeringStatus])
      : deleted = false,
        progress = OrderProgress.notFullyDistributed;

  OrderFilter.notFullyFinished()
      : deleted = false,
        progress = OrderProgress.notFullyFinished,
        offeringStatus = null;

  OrderFilter.fullyFinished()
      : deleted = false,
        progress = OrderProgress.fullyFinished,
        offeringStatus = null;

  @override
  bool operator ==(dynamic other) {
    if (other is! OrderFilter) {
      return false;
    }
    final OrderFilter otherFilter = other;
    return deleted == otherFilter.deleted &&
        progress == otherFilter.progress &&
        offeringStatus == otherFilter.offeringStatus;
  }

  @override
  int get hashCode => hashValues(deleted, progress, offeringStatus);
}

class OrderSort {
  final OrderSortDirection sortDirection;
  final OrderSortType sortType;
  final String key;

  OrderSort.byDefault()
      : sortType = OrderSortType.byDefault,
        key = 'lastProgressDate',
        sortDirection = OrderSortDirection.descending;

  OrderSort.byUnloadingDate()
      : sortType = OrderSortType.byUnloadingDate,
        key = 'unloadingBeginDate',
        sortDirection = OrderSortDirection.descending;

  @override
  bool operator ==(dynamic other) {
    if (other is! OrderSort) {
      return false;
    }
    final OrderSort otherSort = other;
    return sortType == otherSort.sortType &&
        sortDirection == otherSort.sortDirection &&
        key == otherSort.key;
  }

  @override
  int get hashCode => sortType.hashCode + sortDirection.hashCode + key.hashCode;
}

class TariffLimitInformation {
  num baseSaleTariff;
  num baseDeliveryTariff;
  num saleDiscount;
  num deliveryExtraCharge;

  TariffLimitInformation(this.baseSaleTariff, this.baseDeliveryTariff,
      this.saleDiscount, this.deliveryExtraCharge);
}

class OrderServerAPI {
  final ServerManager serverManager;

  OrderServerAPI(this.serverManager);

  Future<Order> getByNumber(int number) async {
    final builder = parse.QueryBuilder(Order.className);
    builder.equalTo('number', number);
    builder.includeAll(_getBaseIncludes());
    builder.limit(1);

    final results = await builder.find(serverManager.server);
    if (results.length == 0) {
      return null;
    }
    final order = Order.decode(Decoder(results[0]));
    if (order == null) {
      throw InvalidResponseException();
    }
    return order;
  }

  Future<List<Order>> list(User user, DateTime sortDate, int limit,
      {OrderFilter filter, OrderSort sort}) async {
    final builder = _makeListQuery(user, filter: filter);
    if (builder == null) {
      return [];
    }

    builder.includeAll(_getBaseIncludes());
    if (sortDate != null) {
      builder.lessThanDate(sort.key, sortDate);
    }
    builder.limit(limit);

    switch (sort.sortDirection) {
      case OrderSortDirection.ascending:
        builder.addAscending(sort.key);
        break;
      case OrderSortDirection.descending:
        builder.addDescending(sort.key);
        break;
      default:
        break;
    }

    final results = await builder.find(serverManager.server);
    return results
        .map((json) => Order.decode(Decoder(json)))
        .where((decoded) => decoded != null)
        .toList();
  }

  Future<List<Order>> listReservations(User user, DateTime date) async {
    final builder = _makeReservationListQuery(user, date);
    builder.includeAll(_getBaseIncludes());
    builder.addDescending('lastProgressDate');
    final results = await builder.findAll(serverManager.server);
    return results
        .map((json) => Order.decode(Decoder(json)))
        .where((decoded) => decoded != null)
        .toList();
  }

  Future<void> create(Order order, User user) async {
    String id;
    if (user.role == Role.customer) {
      id = await _createForCustomer(order);
    } else {
      final data = <String, dynamic>{};
      final encoder = Encoder(data);
      order.encode(encoder);
      id = await parse.create(serverManager.server, Order.className, data);
    }
    order.id = id;
    order.deleted = false;
    order.distributedTonnage = 0;
    order.finishedTonnage = 0;
    order.undistributedTonnage = order.tonnage;
    order.unfinishedTonnage = order.tonnage;
    final fetchedData =
        await parse.getById(serverManager.server, Order.className, id);
    final decoder = Decoder(fetchedData);
    if (decoder.isValid()) {
      order.createdAt = decoder.decodeCreatedAt();
      order.number = decoder.decodeNumber('number');
      order.author = User.decode(decoder.getDecoder('author'));
      order.salePriceType =
          decoder.decodeEnumeration('salePriceType', PriceType.values);
      order.deliveryPriceType =
          decoder.decodeEnumeration('deliveryPriceType', PriceType.values);
      order.status = decoder.decodeString('status');
    }
  }

  Future<void> createReservation(Order reservation) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    reservation.encode(encoder);
    encoder.encodeString('status', OrderStatus.supplyReserved);
    final id = await parse.create(serverManager.server, Order.className, data);
    reservation.id = id;
    reservation.deleted = false;
    reservation.distributedTonnage = 0;
    reservation.finishedTonnage = 0;
    reservation.undistributedTonnage = reservation.tonnage;
    reservation.unfinishedTonnage = reservation.tonnage;
    reservation.status = OrderStatus.supplyReserved;
    final fetchedData =
        await parse.getById(serverManager.server, Order.className, id);
    final decoder = Decoder(fetchedData);
    if (decoder.isValid()) {
      reservation.createdAt = decoder.decodeCreatedAt();
      reservation.number = decoder.decodeNumber('number');
      reservation.author = User.decode(decoder.getDecoder('author'));
      reservation.salePriceType =
          decoder.decodeEnumeration('salePriceType', PriceType.values);
      reservation.deliveryPriceType =
          decoder.decodeEnumeration('deliveryPriceType', PriceType.values);
    }
  }

  Future<void> update(Order oldOrder, Order newOrder) async {
    final oldData = <String, dynamic>{};
    final newData = <String, dynamic>{};
    oldOrder.encode(Encoder(oldData));
    newOrder.encode(ChangeEncoder(Decoder(oldData), Encoder(newData)));
    if (newData.isNotEmpty) {
      await parse.update(
          serverManager.server, Order.className, oldOrder.id, newData);
    }
  }

  Future<void> fetch(Order order) async {
    final data = await parse.getById(
        serverManager.server, Order.className, order.id,
        include: _getBaseIncludes());
    final fetchedOrder = Order.decode(Decoder(data));
    if (fetchedOrder == null) {
      return;
    }
    order.assign(fetchedOrder);
  }

  Future<void> fetchProgress(Order order) async {
    final data = await parse
        .getById(serverManager.server, Order.className, order.id, include: [
      'carriers',
      'carrierOffers',
      'carrierOffers.carrier',
      'offers',
      'offers.transportUnit',
      'offers.transportUnit.driver',
      'offers.transportUnit.driver.carrier',
      'offers.transportUnit.vehicle',
      'offers.transportUnit.vehicle.model',
      'offers.transportUnit.vehicle.model.brand',
      'offers.transportUnit.trailer',
      'offers.trip',
      'offers.trip.historyRecords',
      'offers.trip.problems',
      'historyRecords',
      'historyRecords.user',
      'historyRecords.user.logistician',
      'historyRecords.user.manager',
    ]);

    final decoder = Decoder(data);
    if (decoder.isValid()) {
      order.undistributedTonnage = decoder.decodeNumber('undistributedTonnage');
      order.distributedTonnage = decoder.decodeNumber('distributedTonnage');
      order.unfinishedTonnage = decoder.decodeNumber('unfinishedTonnage');
      order.finishedTonnage = decoder.decodeNumber('finishedTonnage');
      order.status = decoder.decodeString('status');
      order.carriers = decoder.decodeObjectList(
          'carriers', (Decoder decoder) => Carrier.decode(decoder));
      order.carrierOffers = decoder.decodeObjectList(
          'carrierOffers', (Decoder decoder) => CarrierOffer.decode(decoder));
      order.offers = decoder.decodeObjectList(
          'offers', (Decoder decoder) => Offer.decode(decoder));
      order.historyRecords = decoder.decodeObjectList('historyRecords',
          (Decoder decoder) => OrderHistoryRecord.decode(decoder));
    }
  }

  Future<void> fetchCarriers(Order order) async {
    final data = await parse
        .getById(serverManager.server, Order.className, order.id, include: [
      'carriers',
      'carrierOffers',
      'carrierOffers.carrier',
      'historyRecords',
      'historyRecords.user',
      'historyRecords.user.logistician',
      'historyRecords.user.manager',
    ]);
    final decoder = Decoder(data);
    if (decoder.isValid()) {
      order.status = decoder.decodeString('status');
      order.carriers = decoder.decodeObjectList(
          'carriers', (Decoder decoder) => Carrier.decode(decoder));
      order.carrierOffers = decoder.decodeObjectList(
          'carrierOffers', (Decoder decoder) => CarrierOffer.decode(decoder));
      order.historyRecords = decoder.decodeObjectList('historyRecords',
          (Decoder decoder) => OrderHistoryRecord.decode(decoder));
    }
  }

  Future<void> setStatus(Order order, String status) async {
    final parameters = {
      'orderNumber': order.number,
      'status': status,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_setOrderStatus', parameters);
    await fetchProgress(order);
  }

  Future<void> sendOffer(Order order, TransportUnit transportUnit) async {
    final parameters = {
      'orderNumbers': [order.number],
      'transportUnitIds': [transportUnit.id]
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_sendOffers', parameters);
    await fetchProgress(order);
  }

  Future<void> assignTransportUnit(
      Order order, TransportUnit transportUnit) async {
    final parameters = {
      'orderNumber': order.number,
      'transportUnitId': transportUnit.id
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_assignTransportUnit', parameters);
    await fetchProgress(order);
  }

  Future<void> assignCarrier(Order order, Carrier carrier) async {
    final parameters = {
      'orderNumbers': [order.number],
      if (carrier != null) 'carrierIds': [carrier.id] else 'carrierIds': null,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_assignCarriers', parameters);
    await fetchCarriers(order);
  }

  Future<void> reserve(Order order) async {
    final parameters = {
      'orderNumber': order.number,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_reserveOrder', parameters);
    await fetchCarriers(order);
  }

  Future<void> take(Order order) async {
    final parameters = {
      'orderNumber': order.number,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_takeOrder', parameters);
    await fetchCarriers(order);
  }

  Future<void> decline(Order order) async {
    final parameters = {
      'orderNumber': order.number,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_declineOrder', parameters);
    await fetchCarriers(order);
  }

  Future<void> finish(
      Order order,
      DateTime loadedDate,
      num loadedTonnage,
      File loadedPhoto,
      num distance,
      DateTime unloadedDate,
      num unloadedTonnage,
      File unloadedPhoto) async {
    var parameters = <String, dynamic>{
      'orderNumber': order.number,
      if (loadedDate != null) 'loadedDate': loadedDate.millisecondsSinceEpoch,
      if (loadedTonnage != null) 'loadedTonnage': loadedTonnage,
      if (distance != null)
        'loadedAdditionalData': <String, dynamic>{'kilometers': distance},
      if (loadedPhoto != null)
        'loadedPhoto': base64Encode(await loadedPhoto.readAsBytes()),
      'unloadedDate': unloadedDate.millisecondsSinceEpoch,
      'unloadedTonnage': unloadedTonnage,
      if (unloadedPhoto != null)
        'unloadedPhoto': base64Encode(await unloadedPhoto.readAsBytes()),
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_finishOrder', parameters);
    await fetchProgress(order);
  }

  Future<void> consistOrder(Order order) async {
    final dataMap = <String, dynamic>{};
    order.encode(Encoder(dataMap));
    await parse.update(
        serverManager.server, Order.className, order.id, dataMap);
  }

  Future<void> cancel(Order order) async {
    final parameters = {
      'orderNumber': order.number,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_cancelOrder', parameters);
    await fetchProgress(order);
  }

  Future<void> cancelByCustomer(Order order) async {
    final parameters = {
      'orderNumber': order.number,
    };
    await callCloudFunction(
        serverManager.server, 'Customer_cancelOrder', parameters);
  }

  Future<void> delete(Order order) async {
    await markDeleted(serverManager.server, Order.className, order.id);
    order.deleted = true;
  }

  parse.LiveQuerySubscription<Order> subscribe(User user,
          {OrderFilter filter}) =>
      serverManager.liveQueryManager.subscribe(
          _makeListQuery(user, filter: filter),
          (decoder) => Order.decode(decoder));

  parse.LiveQuerySubscription<Order> subscribeToReservations(
          User user, DateTime date) =>
      serverManager.liveQueryManager.subscribe(
          _makeReservationListQuery(user, date),
          (decoder) => Order.decode(decoder));

  parse.LiveQuerySubscription<Order> subscribeToChanges(Order order) =>
      serverManager.liveQueryManager.subscribeToObjectChanges(
          Order.className, order.id, (decoder) => Order.decode(decoder));

  void unsubscribe(parse.LiveQuerySubscription<Order> subscription) =>
      serverManager.liveQueryManager.unsubscribe(subscription);

  Future<String> _createForCustomer(Order order) async {
    final parameters = {
      'unloadingPointId': order.unloadingPoint.id,
      'unloadingBeginDate': order.unloadingBeginDate.millisecondsSinceEpoch,
      'unloadingEndDate': order.unloadingEndDate.millisecondsSinceEpoch,
      'articleBrandId': order.articleBrand.id,
      'tonnage': order.tonnage,
      'comment': order.comment,
    };
    final result = await callCloudFunction(
        serverManager.server, 'Customer_makeOrder', parameters);
    final id = result['id'];
    if (id is! String) {
      throw InvalidResponseException();
    }
    return id;
  }

  parse.QueryBuilder _makeListQuery(User user, {OrderFilter filter}) {
    final builder = parse.QueryBuilder(Order.className);

    if (user.role != Role.customer) {
      builder.equalTo('status', OrderStatus.ready);
    }

    if (user.role == Role.manager) {
      builder.equalToObject('manager', Manager.className, user.manager.id);
    } else if (user.role == Role.dispatcher) {
      builder.equalToObject('carriers', Carrier.className, user.carrier.id);
    } else if (user.role == Role.customer) {
      builder.equalToObject('customer', Customer.className, user.customer.id);
    }

    builder.equalTo('deleted', filter.deleted);

    if (filter.progress != null) {
      switch (filter.progress) {
        case OrderProgress.notFullyDistributed:
          builder.greaterThan('undistributedTonnage', 0);
          if (filter.offeringStatus != null) {
            switch (filter.offeringStatus) {
              case OrderOfferingStatus.none:
                if (user.role == Role.dispatcher) {
                  return null;
                }
                builder.doesNotExist('carriers');
                builder.doesNotExist('offers');
                break;
              case OrderOfferingStatus.carriersOnly:
                if (user.role != Role.dispatcher) {
                  builder.exists('carriers');
                }
                builder.doesNotExist('offers');
                break;
              case OrderOfferingStatus.drivers:
                builder.exists('offers');
                break;
            }
          }
          break;
        case OrderProgress.notFullyFinished:
          builder.greaterThan('distributedTonnage', 0);
          builder.greaterThan('unfinishedTonnage', 0);
          break;
        case OrderProgress.fullyFinished:
          builder.equalTo('unfinishedTonnage', 0);
          break;
      }
    }

    return builder;
  }

  parse.QueryBuilder _makeReservationListQuery(User user, DateTime date) {
    final builder = parse.QueryBuilder(Order.className);
    builder.equalTo('deleted', false);

    if (user.role == Role.dispatcher) {
      if (!user.carrier.orderPermissions.reserveOrder) {
        builder.equalToObject('carriers', Carrier.className, user.carrier.id);
      }
      builder.exists('customer');
      builder.doesNotExist('offers');
    }

    builder.greaterThanOrEqualToDate(
        'unloadingBeginDate', date.beginningOfDay.toUtc());
    builder.lessThanDate('unloadingBeginDate',
        date.add(Duration(days: 1)).beginningOfDay.toUtc());

    return builder;
  }

  List<String> _getBaseIncludes() {
    return [
      'author',
      'author.carrier',
      'articleBrand',
      'articleBrand.type',
      'intermediary',
      'supplier',
      'loadingPoint',
      'transferPoint',
      'loadingEntrance',
      'customer',
      'unloadingPoint',
      'unloadingPoint.manager',
      'unloadingEntrance',
      'carriers',
      'carrierOffers',
      'carrierOffers.carrier',
      'offers',
      'offers.transportUnit',
      'offers.transportUnit.driver',
      'offers.transportUnit.driver.carrier',
      'offers.transportUnit.vehicle',
      'offers.transportUnit.vehicle.model',
      'offers.transportUnit.vehicle.model.brand',
      'offers.transportUnit.trailer',
      'offers.trip',
      'offers.trip.historyRecords',
      'offers.trip.problems',
      'historyRecords',
      'historyRecords.user',
      'historyRecords.user.logistician',
      'historyRecords.user.manager',
    ];
  }
}
