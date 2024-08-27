import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'trip_history_record.dart';
import 'trip_problem.dart';

export 'trip_history_record.dart';
export 'trip_problem.dart';

class Trip extends Identifiable<String> {
  String id;
  TripStage stage;
  List<TripHistoryRecord> historyRecords;
  List<TripProblem> problems;

  Trip();

  static const className = 'Trip';

  factory Trip.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Trip();

    decoded.id = decoder.decodeId();
    decoded.stage = decoder.decodeEnumeration('stage', TripStage.values);
    decoded.historyRecords = decoder.decodeObjectList('historyRecords', (Decoder decoder) => TripHistoryRecord.decode(decoder));
    decoded.problems = decoder.decodeObjectList('problems', (Decoder decoder) => TripProblem.decode(decoder));

    if (decoded.historyRecords != null) {
      if (decoded.historyRecords.every((record) => record.stage != null)) {
        decoded.historyRecords.sort((one, other) => one.stage.index.compareTo(other.stage.index));
      }
    }

    return decoded;
  }
}

extension TripUtility on Trip {
  TripHistoryRecord getHistoryRecord(TripStage stage) {
    if (historyRecords == null) {
      return null;
    }
    return historyRecords.firstWhere((record) => record.stage == stage, orElse: () => null);
  }
}
