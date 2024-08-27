import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';
import 'article_type.dart';

export 'article_type.dart';

class ArticleBrand extends Identifiable<String> implements DeletionMarking {
  String id;
  String name;
  ArticleType type;
  num tonnagePerTruck;
  bool deleted;

  ArticleBrand();

  static const className = 'ArticleBrand';

  factory ArticleBrand.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = ArticleBrand();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.type = ArticleType.decode(decoder.getDecoder('type'));
    decoded.tonnagePerTruck = decoder.decodeNumber('tonnagePerTruck');
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }
}
