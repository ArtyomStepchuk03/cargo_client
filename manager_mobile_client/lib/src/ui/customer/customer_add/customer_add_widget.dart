import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/src/logic/server_api/unloading_point_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/remote_file_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'customer_add_strings.dart' as strings;
import 'customer_add_body.dart';

class CustomerAddWidget extends StatefulWidget {
  final Manager manager;

  CustomerAddWidget({this.manager});

  @override
  State<StatefulWidget> createState() => CustomerAddState();
}

class CustomerAddState extends State<CustomerAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: CustomerAddBody(key: _bodyKey),
    );
  }

  final _bodyKey = GlobalKey<CustomerAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final createInformation = _bodyKey.currentState.validate();
    if (createInformation != null) {
      showActivityDialog(context, strings.saving);

      final dependencyState = DependencyHolder.of(context);
      final serverAPI = dependencyState.network.serverAPI;
      final placesService = dependencyState.location.placesService;

      try {
        final bool exist = await serverAPI.customers.exists(createInformation.name);
        if (exist) {
          Navigator.pop(context);
          showErrorDialog(context, strings.customerExists);
          return;
        }

        final customer = await _createCustomer(serverAPI.customers, serverAPI.files, createInformation);
        final unloadingPoint = await _addUnloadingPoint(serverAPI.customers, customer, createInformation);
        await _addEntrance(serverAPI.unloadingPoints, placesService, unloadingPoint, createInformation);

        Navigator.pop(context);
        Navigator.pop(context, customer);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  Future<Customer> _createCustomer(
    CustomerServerAPI customerServerAPI,
    RemoteFileServerAPI remoteFileServerAPI,
    CustomerCreateInformation createInformation
  ) async {
    final customer = Customer();

    customer.name = createInformation.name;
    if (createInformation.contactName != null || createInformation.contactPhoneNumber != null) {
      customer.contacts = [Contact(name: createInformation.contactName, phoneNumber: createInformation.contactPhoneNumber)];
    }
    customer.name = createInformation.name;
    customer.priceType = createInformation.priceType;

    if (createInformation.files != null) {
      customer.attachedDocuments = [];
      for (final file in createInformation.files) {
        final remoteFile = await remoteFileServerAPI.createImage(file);
        customer.attachedDocuments.add(remoteFile);
      }
    }

    await customerServerAPI.create(customer);
    return customer;
  }

  Future<UnloadingPoint> _addUnloadingPoint(
    CustomerServerAPI customerServerAPI,
    Customer customer,
    CustomerCreateInformation createInformation
  ) async {
    final unloadingPoint = UnloadingPoint();
    unloadingPoint.address = createInformation.address;
    await customerServerAPI.addUnloadingPoint(customer, unloadingPoint, widget.manager);
    return unloadingPoint;
  }

  Future<Entrance> _addEntrance(
    UnloadingPointServerAPI unloadingPointServerAPI,
    PlacesService placesService,
    UnloadingPoint unloadingPoint,
    CustomerCreateInformation createInformation
  ) async {
    final entrance = Entrance();
    entrance.name = strings.defaultEntranceName;
    entrance.address = createInformation.address;
    if (createInformation.placesSearchResult != null) {
      final detailsResult = await placesService.getDetails(createInformation.placesSearchResult);
      entrance.coordinate = detailsResult.coordinate;
    } else {
      final detailsResult = await placesService.getCoordinate(createInformation.address);
      entrance.coordinate = detailsResult.coordinate;
    }
    await unloadingPointServerAPI.addEntrance(unloadingPoint, entrance);
    return entrance;
  }
}
