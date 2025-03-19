import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';

import 'article_brand.dart';
import 'contact.dart';
import 'loading_point.dart';

export 'contact.dart';
export 'loading_point.dart';

class Supplier extends Identifiable<String> implements DeletionMarking {
  String? id;
  String? name;
  String? itn;
  List<Contact?>? contacts;
  List<ArticleBrand?>? articleBrands;
  List<LoadingPoint?>? loadingPoints;
  bool? transfer;
  bool? deleted;

  Supplier();

  static const className = 'Supplier';

  static Supplier? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Supplier();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.itn = decoder.decodeString('ITN');
    decoded.contacts =
        decoder.decodeMapList('contacts', (data) => Contact.decode(data));
    decoded.articleBrands = decoder.decodeObjectList(
        'articleBrands', (Decoder decoder) => ArticleBrand.decode(decoder));
    decoded.loadingPoints = decoder.decodeObjectList(
        'loadingPoints', (Decoder decoder) => LoadingPoint.decode(decoder));
    decoded.transfer = decoder.decodeBooleanDefault('transfer');
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }
}
