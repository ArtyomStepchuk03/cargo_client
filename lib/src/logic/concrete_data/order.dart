import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

import 'article_brand.dart';
import 'article_shape.dart';
import 'carrier_offer.dart';
import 'customer.dart';
import 'intermediary.dart';
import 'offer.dart';
import 'order_history_record.dart';
import 'supplier.dart';
import 'user.dart';

export 'article_brand.dart';
export 'article_shape.dart';
export 'carrier_offer.dart';
export 'customer.dart';
export 'intermediary.dart';
export 'offer.dart';
export 'order_history_record.dart';
export 'supplier.dart';

class OrderType {
  final String? raw;

  OrderType(this.raw);

  OrderType.normal() : this(null);

  OrderType.carriage() : this('carriage');

  @override
  bool operator ==(dynamic other) {
    if (other is! OrderType) {
      return false;
    }
    final OrderType otherType = other;
    return raw == otherType.raw;
  }

  @override
  int get hashCode => raw.hashCode;
}

class AgreeOrderType {
  final String? raw;

  AgreeOrderType(this.raw);

  AgreeOrderType.agree() : this('agree');

  AgreeOrderType.notAgree() : this('not_agree');

  @override
  bool operator ==(dynamic other) {
    if (other is! AgreeOrderType) {
      return false;
    }
    final AgreeOrderType agreeOrderType = other;
    return raw == agreeOrderType.raw;
  }

  @override
  int get hashCode => raw.hashCode;
}

class OrderStatus {
  static const customerRequest = 'customerRequest';
  static const supplyReserved = 'supplyReserved';
  static const inWork = 'inWork';
  static const ready = 'ready';
}

class Order extends Identifiable<String> {
  String? id;
  DateTime? createdAt;
  int? number;
  String? type;
  String? consistency;
  User? author;

  ArticleShape? articleShape;
  ArticleBrand? articleBrand;

  Intermediary? intermediary;

  Supplier? supplier;
  LoadingPoint? loadingPoint;
  Entrance? loadingEntrance;
  DateTime? loadingDate;

  Customer? customer;
  UnloadingPoint? unloadingPoint;
  Entrance? unloadingEntrance;
  Contact? unloadingContact;
  DateTime? unloadingBeginDate;
  DateTime? unloadingEndDate;

  num? tonnage;
  num? distance;
  num? undistributedTonnage;
  num? distributedTonnage;
  num? unfinishedTonnage;
  num? finishedTonnage;

  num? saleTariff;
  PriceType? salePriceType;
  num? deliveryTariff;
  PriceType? deliveryPriceType;
  String? comment;
  int? inactivityTimeInterval;

  String? status;
  List<Carrier?>? carriers;
  List<CarrierOffer?>? carrierOffers;
  List<Offer?>? offers;
  List<OrderHistoryRecord?>? historyRecords;
  DateTime? lastProgressDate;

  bool? deleted;

  Order()
      : distributedTonnage = 0,
        finishedTonnage = 0;

  void assign(Order? other) {
    id = other?.id;
    createdAt = other?.createdAt;
    number = other?.number;
    type = other?.type;
    author = other?.author;
    articleShape = other?.articleShape;
    articleBrand = other?.articleBrand;
    intermediary = other?.intermediary;
    supplier = other?.supplier;
    loadingPoint = other?.loadingPoint;
    loadingEntrance = other?.loadingEntrance;
    loadingDate = other?.loadingDate;
    customer = other?.customer;
    unloadingPoint = other?.unloadingPoint;
    unloadingEntrance = other?.unloadingEntrance;
    unloadingContact = other?.unloadingContact;
    unloadingBeginDate = other?.unloadingBeginDate;
    unloadingEndDate = other?.unloadingEndDate;
    tonnage = other?.tonnage;
    distance = other?.distance;
    undistributedTonnage = other?.undistributedTonnage;
    distributedTonnage = other?.distributedTonnage;
    unfinishedTonnage = other?.unfinishedTonnage;
    finishedTonnage = other?.finishedTonnage;
    saleTariff = other?.saleTariff;
    salePriceType = other?.salePriceType;
    deliveryTariff = other?.deliveryTariff;
    deliveryPriceType = other?.deliveryPriceType;
    comment = other?.comment;
    inactivityTimeInterval = other?.inactivityTimeInterval;
    status = other?.status;
    carriers = other?.carriers;
    carrierOffers = other?.carrierOffers;
    offers = other?.offers;
    historyRecords = other?.historyRecords;
    lastProgressDate = other?.lastProgressDate;
    deleted = other?.deleted;
  }

  static const className = 'Order';

  static Order? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Order();

    decoded.id = decoder.decodeId();
    decoded.createdAt = decoder.decodeCreatedAt();
    decoded.number = decoder.decodeNumber('number') as int?;
    decoded.type = decoder.decodeString('type');
    decoded.author = User.decode(decoder.getDecoder('author'));

    decoded.articleBrand =
        ArticleBrand.decode(decoder.getDecoder('articleBrand'));

    decoded.intermediary =
        Intermediary.decode(decoder.getDecoder('intermediary'));

    decoded.supplier = Supplier.decode(decoder.getDecoder('supplier'));
    decoded.loadingPoint =
        LoadingPoint.decode(decoder.getDecoder('loadingPoint'));
    decoded.loadingEntrance =
        Entrance.decode(decoder.getDecoder('loadingEntrance'));
    decoded.loadingDate = decoder.decodeDate('loadingDate');

    decoded.customer = Customer.decode(decoder.getDecoder('customer'));
    decoded.unloadingPoint =
        UnloadingPoint.decode(decoder.getDecoder('unloadingPoint'));
    decoded.unloadingEntrance =
        Entrance.decode(decoder.getDecoder('unloadingEntrance'));
    decoded.unloadingContact =
        Contact.decode(decoder.decodeMap('unloadingContact'));
    decoded.unloadingBeginDate = decoder.decodeDate('unloadingBeginDate');
    decoded.unloadingEndDate = decoder.decodeDate('unloadingEndDate');

    decoded.tonnage = decoder.decodeNumber('tonnage');
    decoded.distance = decoder.decodeNumber('distance');
    decoded.undistributedTonnage = decoder.decodeNumber('undistributedTonnage');
    decoded.distributedTonnage = decoder.decodeNumber('distributedTonnage');
    decoded.unfinishedTonnage = decoder.decodeNumber('unfinishedTonnage');
    decoded.finishedTonnage = decoder.decodeNumber('finishedTonnage');

    decoded.saleTariff = decoder.decodeNumber('saleTariff');
    decoded.salePriceType =
        decoder.decodeEnumeration('salePriceType', PriceType.values);
    decoded.deliveryTariff = decoder.decodeNumber('deliveryTariff');
    decoded.deliveryPriceType =
        decoder.decodeEnumeration('deliveryPriceType', PriceType.values);
    decoded.comment = decoder.decodeString('comment');
    decoded.inactivityTimeInterval =
        decoder.decodeNumber('inactivityTimeInterval') as int?;

    decoded.status = decoder.decodeString('status');
    decoded.carriers = decoder.decodeObjectList(
        'carriers', (Decoder decoder) => Carrier.decode(decoder));
    decoded.carrierOffers = decoder.decodeObjectList(
        'carrierOffers', (Decoder decoder) => CarrierOffer.decode(decoder));
    decoded.offers = decoder.decodeObjectList(
        'offers', (Decoder decoder) => Offer.decode(decoder));
    decoded.historyRecords = decoder.decodeObjectList('historyRecords',
        (Decoder decoder) => OrderHistoryRecord.decode(decoder));
    decoded.lastProgressDate = decoder.decodeDate('lastProgressDate');

    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    decoded.consistency = decoder.decodeString('consistency');
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('type', type);

    encoder.encodePointer(
        'articleBrand', ArticleBrand.className, articleBrand?.id);

    encoder.encodePointer(
        'intermediary', Intermediary.className, intermediary?.id);

    encoder.encodePointer('supplier', Supplier.className, supplier?.id);
    encoder.encodePointer(
        'loadingPoint', LoadingPoint.className, loadingPoint?.id);
    encoder.encodePointer(
        'loadingEntrance', Entrance.className, loadingEntrance?.id);
    encoder.encodeDate('loadingDate', loadingDate);

    encoder.encodePointer('customer', Customer.className, customer?.id);
    encoder.encodePointer(
        'unloadingPoint', UnloadingPoint.className, unloadingPoint?.id);
    encoder.encodePointer(
        'unloadingEntrance', Entrance.className, unloadingEntrance?.id);
    encoder.encodeMap('unloadingContact', unloadingContact?.encode());
    encoder.encodeDate('unloadingBeginDate', unloadingBeginDate);
    encoder.encodeDate('unloadingEndDate', unloadingEndDate);

    encoder.encodeNumber('tonnage', tonnage);
    encoder.encodeNumber('distance', distance);
    encoder.encodeNumber('saleTariff', saleTariff);
    encoder.encodeNumber('salePriceType', salePriceType?.index);
    encoder.encodeNumber('deliveryTariff', deliveryTariff);
    encoder.encodeNumber('deliveryPriceType', deliveryPriceType?.index);
    encoder.encodeString('comment', comment);
    encoder.encodeNumber('inactivityTimeInterval', inactivityTimeInterval);
    encoder.encodeString('consistency', consistency);
  }
}

extension OrderUtility on Order {
  Offer? getAcceptedOffer() {
    if (offers == null) {
      return null;
    }
    return offers?.firstWhere((offer) => offer?.trip != null,
        orElse: () => null);
  }

  bool isQueue() {
    if (offers == null || offers!.isEmpty) return false;
    return offers?.first?.isQueue == true;
  }

  CarrierOffer? getCarrierOffer(Carrier? carrier) {
    if (carrierOffers == null) {
      return null;
    }
    return carrierOffers
        ?.firstWhere((carrierOffer) => carrierOffer?.carrier == carrier);
  }

  OrderHistoryRecord? getTakenIntoWorkHistoryRecord() {
    if (historyRecords == null) {
      return null;
    }
    return historyRecords?.firstWhere((historyRecord) =>
        historyRecord?.action == OrderHistoryAction.takenIntoWork);
  }

  bool hasTripOnMinimumStage(TripStage tripStage) {
    if (offers == null) {
      return false;
    }
    return offers!.any((offer) {
      if (offer?.trip?.stage == null) {
        return false;
      }
      return offer!.trip!.stage!.index >= tripStage.index;
    });
  }
}
