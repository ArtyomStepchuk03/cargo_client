import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class UnloadingPointServerAPI {
  final ServerManager serverManager;

  UnloadingPointServerAPI(this.serverManager);

  Future<void> fetch(UnloadingPoint? unloadingPoint) async {
    final data = await parse.getById(
        serverManager.server!, UnloadingPoint.className, unloadingPoint?.id,
        include: ['entrances', 'manager']);
    final fetchedUnloadingPoint = UnloadingPoint.decode(Decoder(data));
    if (fetchedUnloadingPoint == null) {
      return;
    }
    unloadingPoint?.assign(fetchedUnloadingPoint);
  }

  Future<void> fetchEntrances(UnloadingPoint? unloadingPoint) async {
    final fetched = await parse.getById(
        serverManager.server!, UnloadingPoint.className, unloadingPoint?.id,
        include: ['entrances']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    unloadingPoint?.entrances = Decoder(fetched).decodeObjectList(
        'entrances', (Decoder decoder) => Entrance.decode(decoder));
  }

  Future<void> addContact(
      UnloadingPoint? unloadingPoint, Contact? contact) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    ListEncoder listEncoder = encoder.getAddOperationListEncoder('contacts');
    listEncoder.addMap(contact?.encode());

    await parse.update(serverManager.server!, UnloadingPoint.className,
        unloadingPoint?.id, data);
    if (unloadingPoint?.contacts != null) {
      unloadingPoint!.contacts!.add(contact);
    } else {
      unloadingPoint?.contacts = [contact];
    }
  }

  Future<void> removeContact(
      UnloadingPoint? unloadingPoint, Contact? contact) async {
    final parameters = {
      'unloadingPointId': unloadingPoint?.id,
      'contactNumber': contact?.phoneNumber,
    };
    await callCloudFunction(
        serverManager.server!, 'Customer_removeContact', parameters);
  }

  Future<void> addEntrance(
      UnloadingPoint? unloadingPoint, Entrance? entrance) async {
    final entranceData = <String, dynamic>{};
    final entranceEncoder = Encoder(entranceData);
    entrance?.encode(entranceEncoder);

    final id = await parse.create(
        serverManager.server!, Entrance.className, entranceData);
    entrance?.id = id;
    entrance?.deleted = false;

    final unloadingPointData = <String, dynamic>{};
    final unloadingPointEncoder = Encoder(unloadingPointData);
    ListEncoder listEncoder =
        unloadingPointEncoder.getAddOperationListEncoder('entrances');
    listEncoder.addPointer(Entrance.className, entrance?.id);

    await parse.update(serverManager.server!, UnloadingPoint.className,
        unloadingPoint?.id, unloadingPointData);
    if (unloadingPoint?.entrances != null) {
      unloadingPoint!.entrances!.add(entrance);
    } else {
      unloadingPoint!.entrances = [entrance];
    }
  }
}
