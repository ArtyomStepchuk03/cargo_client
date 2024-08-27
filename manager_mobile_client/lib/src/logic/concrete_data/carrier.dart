import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';
import 'supplier.dart';
import 'customer.dart';

class OrderPermissions {
  final bool create;
  final bool update;
  final bool delete;
  final bool salePrice;
  final bool reserveOrder;

  OrderPermissions({this.create, this.update, this.delete, this.salePrice, this.reserveOrder});

  factory OrderPermissions.decode(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    return OrderPermissions(
      create: data['create'] ?? false,
      update: data['update'] ?? false,
      delete: data['delete'] ?? false,
      salePrice: data['salePrice'] ?? false,
      reserveOrder: data['reserveOrder'] ?? false,
    );
  }
}

class Carrier extends Identifiable<String> {
  String id;
  String name;
  OrderPermissions orderPermissions;
  List<Supplier> suppliers;
  List<Customer> customers;
  bool showAllSuppliers;
  bool showAllCustomers;

  Carrier();

  static const className = 'Carrier';

  factory Carrier.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Carrier();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.orderPermissions = OrderPermissions.decode(decoder.decodeMap('orderPermissions'));
    decoded.suppliers = decoder.decodeObjectList('suppliers', (Decoder decoder) => Supplier.decode(decoder))?.excludeDeleted();
    decoded.customers = decoder.decodeObjectList('customers', (Decoder decoder) => Customer.decode(decoder))?.excludeDeleted();
    decoded.showAllSuppliers = decoder.decodeBooleanDefault('showAllSuppliers');
    decoded.showAllCustomers = decoder.decodeBooleanDefault('showAllCustomers');
    return decoded;
  }
}
