import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'user.dart';

class OrderHistoryAction {
  static const canceledByCustomer = 'canceledByCustomer';
  static const takenIntoWork = 'takenIntoWork';
}

class OrderHistoryRecord extends Identifiable<String> {
  String id;
  DateTime date;
  String action;
  User user;

  OrderHistoryRecord();

  static const className = 'OrderHistoryRecord';

  factory OrderHistoryRecord.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = OrderHistoryRecord();
    decoded.id = decoder.decodeId();
    decoded.date = decoder.decodeDate('date');
    decoded.action = decoder.decodeString('action');
    decoded.user = User.decode(decoder.getDecoder('user'));
    return decoded;
  }
}
