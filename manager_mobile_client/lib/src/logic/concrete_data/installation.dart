import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'user.dart';

export 'user.dart';

class Installation extends Identifiable<String> {
  String id;
  User user;

  Installation();

  factory Installation.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Installation();

    decoded.id = decoder.decodeId();
    decoded.user = User.decode(decoder.getDecoder('user'));

    return decoded;
  }
}
