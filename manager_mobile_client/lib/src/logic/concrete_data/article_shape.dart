import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

class ArticleShape extends Identifiable<String> {
  String id;
  String name;

  ArticleShape();

  static const className = 'ArticleShape';

  factory ArticleShape.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = ArticleShape();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    return decoded;
  }
}
