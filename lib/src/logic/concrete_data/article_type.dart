import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

class ArticleType extends Identifiable<String> {
  String? id;
  String? name;
  bool? deleted;

  ArticleType();

  static const className = 'ArticleType';

  static ArticleType? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = ArticleType();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }
}
