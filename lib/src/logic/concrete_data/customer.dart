import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';

import 'unloading_point.dart';

export 'unloading_point.dart';

enum PriceType { oneTime, notOneTime }

class CustomerPermissions {
  final bool driverPhoneNumber;

  CustomerPermissions({required this.driverPhoneNumber});

  static CustomerPermissions? decode(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    return CustomerPermissions(
      driverPhoneNumber: data['driverPhoneNumber'] ?? false,
    );
  }
}

class Customer extends Identifiable<String> implements DeletionMarking {
  String? id;
  String? name;
  String? itn;
  List<Contact?>? contacts;
  PriceType? priceType;
  List<UnloadingPoint?>? unloadingPoints;
  List<RemoteFile?>? attachedDocuments;
  CustomerPermissions? permissions;
  bool? internal;
  bool? deleted;

  static const className = 'Customer';

  static Customer? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Customer();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.itn = decoder.decodeString('ITN');
    decoded.contacts =
        decoder.decodeMapList('contacts', (data) => Contact.decode(data));
    decoded.priceType =
        decoder.decodeEnumeration('priceType', PriceType.values);
    decoded.unloadingPoints = decoder.decodeObjectList(
        'unloadingPoints', (Decoder decoder) => UnloadingPoint.decode(decoder));
    decoded.permissions =
        CustomerPermissions.decode(decoder.decodeMap('permissions'));
    decoded.internal = decoder.decodeBooleanDefault('internal');
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('name', name);
    encoder.encodeList(
        'contacts',
        contacts,
        (ListEncoder listEncoder, Contact? contact) =>
            listEncoder.addMap(contact?.encode()));
    encoder.encodeNumber('priceType', priceType!.index);
    encoder.encodeList(
        'attachedDocuments',
        attachedDocuments,
        (ListEncoder listEncoder, RemoteFile? file) =>
            listEncoder.addFile(file));
  }
}
