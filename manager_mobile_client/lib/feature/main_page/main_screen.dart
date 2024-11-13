import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

enum MainScreen {
  reservations,
  orders,
  customers,
  suppliers,
  transportUnits,
  messages,
  myData,
}

List<MainScreen> buildMainScreens(User user) {
  return [
    if (Role.isManagerOrHigher(user.role) || Role.isDispatcherOrHigher(user.role))
      MainScreen.reservations,
    MainScreen.orders,
    if (Role.isManagerOrHigher(user.role)) ...[
      MainScreen.customers,
      MainScreen.suppliers,
    ],
    if (Role.isManagerOrHigher(user.role) || Role.isDispatcherOrHigher(user.role))
      MainScreen.transportUnits,
    if (Role.isLogisticianOrHigher(user.role))
      MainScreen.messages,
    if (user.role == Role.customer)
      MainScreen.myData,
  ];
}
