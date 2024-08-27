import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/floating_action_button.dart';
import 'carrier_search/carrier_search.dart';
import 'carrier_list_body.dart';
import 'carrier_list_strings.dart' as strings;

class CarrierListWidget extends StatefulWidget {
  final bool selecting;
  final String confirmButtonTitle;
  final ItemConfirmCallback<Carrier> onConfirm;
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  CarrierListWidget({this.selecting = false, this.confirmButtonTitle, this.onConfirm, this.drawer, this.containerBuilder});

  @override
  State<StatefulWidget> createState() => CarrierListState();
}

class CarrierListState extends State<CarrierListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      drawer: widget.drawer,
      body: _buildContainer(context, _buildBody()),
      floatingActionButton: _buildConfirmButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  final _bodyKey = GlobalKey<CarrierListBodyState>();
  Carrier _selectedValue;

  List<Widget> _buildActions(BuildContext context) {
    return [
      _buildSearchButton(context),
    ];
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showCarrierSearch(
          context: context,
          onTap: (Carrier carrier) {
            if (!widget.selecting) {
              return;
            }
            Navigator.pop(context);
            _bodyKey.currentState.select(carrier);
            setState(() => _selectedValue = carrier);
          },
        );
      },
    );
  }

  bool _needsConfirmButton() => widget.selecting && widget.confirmButtonTitle != null && widget.onConfirm != null && _selectedValue != null;

  Widget _buildConfirmButton(context) {
    if (!_needsConfirmButton()) {
      return null;
    }
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Container(),
        label: Text(widget.confirmButtonTitle),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => widget.onConfirm(_selectedValue),
      ),
    );
  }

  Widget _buildBody() {
    return CarrierListBody(
      key: _bodyKey,
      selecting: widget.selecting,
      initialValue: _selectedValue,
      onSelect: (Carrier carrier) {
        setState(() => _selectedValue = carrier);
      },
      insetForFloatingActionButton: _needsConfirmButton(),
    );
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    if (widget.containerBuilder != null) {
      return widget.containerBuilder(context, child);
    }
    return child;
  }
}
