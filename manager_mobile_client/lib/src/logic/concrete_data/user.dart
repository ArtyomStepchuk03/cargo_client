import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'logistician.dart';
import 'manager.dart';
import 'dispatcher.dart';
import 'driver.dart';
import 'customer.dart';
import 'supplier.dart';

export 'carrier.dart';

class Role {
  static const administrator = 'Administrator';
  static const logistician = 'Logistician';
  static const manager = 'Manager';
  static const dispatcher = 'Dispatcher';
  static const driver = 'Driver';
  static const customer = 'Customer';
  static const supplier = 'Supplier';

  static bool isLogisticianOrHigher(String role) => role == logistician || role == administrator;
  static bool isManagerOrHigher(String role) => role == manager || isLogisticianOrHigher(role);
  static bool isDispatcherOrHigher(String role) => role == dispatcher || isLogisticianOrHigher(role);
}

class User extends Identifiable<String> {
  String id;
  String name;
  String sessionToken;
  String role;
  Logistician logistician;
  Manager manager;
  Dispatcher dispatcher;
  Driver driver;
  Customer customer;
  Supplier supplier;
  Carrier carrier;

  User();

  factory User.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = User();

    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeUserName();
    decoded.sessionToken = decoder.decodeSessionToken();
    decoded.role = decoder.decodeString('role');
    decoded.logistician = Logistician.decode(decoder.getDecoder('logistician'));
    decoded.manager = Manager.decode(decoder.getDecoder('manager'));
    decoded.dispatcher = Dispatcher.decode(decoder.getDecoder('dispatcher'));
    decoded.driver = Driver.decode(decoder.getDecoder('driver'));
    decoded.customer = Customer.decode(decoder.getDecoder('customer'));
    decoded.supplier = Supplier.decode(decoder.getDecoder('supplier'));
    decoded.carrier = Carrier.decode(decoder.getDecoder('carrier'));

    return decoded;
  }
}

extension UserPermissions on User {
  bool canAddOrders() {
    if (Role.isManagerOrHigher(role)) {
      return true;
    }
    if (role == Role.dispatcher) {
      return carrier.orderPermissions.create;
    }
    if (role == Role.customer) {
      return true;
    }
    return false;
  }

  bool canEditOrders() {
    if (Role.isManagerOrHigher(role)) {
      return true;
    }
    if (role == Role.dispatcher) {
      return carrier.orderPermissions.update;
    }
    if (role == Role.customer) {
      return true;
    }
    return false;
  }

  bool canDeleteOrders() {
    if (Role.isManagerOrHigher(role)) {
      return true;
    }
    if (role == Role.dispatcher) {
      return carrier.orderPermissions.delete;
    }
    return false;
  }

  bool canManageOrderSalePrice() {
    if (Role.isManagerOrHigher(role)) {
      return true;
    }
    if (role == Role.dispatcher) {
      return carrier.orderPermissions.salePrice;
    }
    return false;
  }

  bool canReserveOrders() {
    if (Role.isManagerOrHigher(role)) {
      return true;
    }
    if (role == Role.dispatcher) {
      return carrier.orderPermissions.reserveOrder;
    }
    return false;
  }

  bool canAccessDriverPhoneNumber() {
    if (Role.isManagerOrHigher(role) || Role.isDispatcherOrHigher(role)) {
      return true;
    }
    if (role == Role.customer) {
      return customer.permissions.driverPhoneNumber;
    }
    return false;
  }

  bool canAddCustomers() => Role.isManagerOrHigher(role);
  bool canAddUnloadingPoints() => Role.isManagerOrHigher(role) || role == Role.customer;
  bool canAddUnloadingEntrances() => Role.isManagerOrHigher(role);
  bool canAddUnloadingContacts() => Role.isManagerOrHigher(role) || role == Role.customer;
  bool canAddTransportUnits() => Role.isManagerOrHigher(role) || Role.isDispatcherOrHigher(role);

  bool canAssignCarriers() => Role.isManagerOrHigher(role);
}
