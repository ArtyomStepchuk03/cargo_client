import 'package:manager_mobile_client/src/logic/concrete_data/offer.dart';
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_manager.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/offer.dart';

class OfferServerAPI {
  final ServerManager serverManager;

  OfferServerAPI(this.serverManager);

  parse.LiveQuerySubscription<Offer> subscribeToChanges(Offer offer) => serverManager.liveQueryManager.subscribeToObjectChanges(Offer.className, offer.id, (decoder) => Offer.decode(decoder));
  void unsubscribe(parse.LiveQuerySubscription<Offer> subscription) => serverManager.liveQueryManager.unsubscribe(subscription);
}
