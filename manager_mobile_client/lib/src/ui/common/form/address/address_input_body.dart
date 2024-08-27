import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/src/ui/utility/data_load_status.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_activity_widget.dart';

class AddressInputResult {
  final String address;
  final PlacesSearchResult placesSearchResult;
  AddressInputResult(this.address, {this.placesSearchResult});
}

class AddressInputBody extends StatefulWidget {
  final PlacesService placesService;
  final String query;

  AddressInputBody({this.placesService, this.query});

  @override
  State createState() => AddressInputBodyState();
}

class AddressInputBodyState extends State<AddressInputBody> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStatus == null) {
      _loadStatus = DataLoadStatus.inProgress();
      _search(widget.query);
    }
  }

  @override
  void didUpdateWidget(AddressInputBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      _loadStatus = DataLoadStatus.inProgress();
      _search(widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadStatus.inProgress) {
      return FullscreenActivityWidget();
    }
    if (_loadStatus.failed) {
      return buildFullscreenError();
    }
    return ListView.builder(
      padding: EdgeInsets.all(4),
      itemCount: _loadStatus.result.length,
      itemBuilder: (context, index) {
        final searchResult = _loadStatus.result[index];
        return _buildItem(searchResult);
      },
    );
  }

  DataLoadStatus<List<PlacesSearchResult>, Exception> _loadStatus;

  Widget _buildItem(PlacesSearchResult searchResult) {
    return InkWell(
      child: ListTile(title: Text(searchResult.description)),
      onTap: () => _select(searchResult),
    );
  }

  void _select(PlacesSearchResult searchResult) {
    Navigator.pop(context, AddressInputResult(searchResult.description, placesSearchResult: searchResult));
  }

  void _search(String query) async {
    DataLoadStatus<List<PlacesSearchResult>, Exception> status;
    try {
      final searchResults = await widget.placesService.search(query);
      status = DataLoadStatus.succeeded(searchResults);
    } catch (exception) {
      status = DataLoadStatus.failed(exception);
    }
    if (!mounted) {
      return;
    }
    if (query != widget.query) {
      return;
    }
    setState(() => _loadStatus = status);
  }
}
