import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

enum TripProblemType {
  breakage,
  inactivity,
  delay,
  stoppage
}

class TripProblem extends Identifiable<String> {
  String id;
  TripProblemType type;
  DateTime date;

  TripProblem();

  static const className = 'TripProblem';

  factory TripProblem.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = TripProblem();
    decoded.id = decoder.decodeId();
    decoded.type = decoder.decodeEnumeration('type', TripProblemType.values);
    decoded.date = decoder.decodeDate('date');
    return decoded;
  }
}
