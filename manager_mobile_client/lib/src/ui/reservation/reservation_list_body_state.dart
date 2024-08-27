import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';

abstract class ReservationListBodyState {
  void addReservation(Order reservation);
  void removeReservation(Order reservation);
  void updateReservation(Order reservation);
}
