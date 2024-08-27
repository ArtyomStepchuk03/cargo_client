import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

extension OrderActionCheck on Order {
  bool isActionsAllowedForDispatcher(User user) {
    if (author != null && author == user) {
      return true;
    }
    final accepted = getCarrierOffer(user.carrier)?.accepted;
    return accepted != null && accepted;
  }

  bool canAcceptCarrierOffer(User user) => _canChangeCarrierOfferStatus(user, true);
  bool canDeclineCarrierOffer(User user) => _canChangeCarrierOfferStatus(user, false);

  bool _canChangeCarrierOfferStatus(User user, bool accept) {
    if (user.role != Role.dispatcher) {
      return false;
    }
    if (offers != null && offers.isNotEmpty) {
      return false;
    }
    final carrierOffer = getCarrierOffer(user.carrier);
    if (carrierOffer == null) {
      return false;
    }
    if (carrierOffer.accepted == null) {
      return true;
    }
    return accept != carrierOffer.accepted;
  }
}
