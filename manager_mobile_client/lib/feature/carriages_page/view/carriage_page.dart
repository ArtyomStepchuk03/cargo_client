import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/feature/carriages_page/widget/carriage_search/carriage_search.dart';
import 'package:manager_mobile_client/feature/carriages_page/widget/carriages_list_body.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/types.dart';

class CarriagePage extends StatefulWidget {
  final bool selecting;
  final String confirmButtonTitle;
  final ItemConfirmCallback<Carrier> onConfirm;
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  CarriagePage({
    this.selecting = false,
    this.confirmButtonTitle,
    this.onConfirm,
    this.drawer,
    this.containerBuilder,
  });

  @override
  State<StatefulWidget> createState() => _CarriagePageState();
}

class _CarriagePageState extends State<CarriagePage> {
  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.carriers),
        actions: [
          _buildSearchButton(context),
        ],
      ),
      drawer: widget.drawer,
      body: _buildContainer(context, _buildBody()),
      floatingActionButton: _buildConfirmButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  final _bodyKey = GlobalKey<CarriagesListBodyState>();
  Carrier _selectedValue;

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

  bool _needsConfirmButton() =>
      widget.selecting &&
      widget.confirmButtonTitle != null &&
      widget.onConfirm != null &&
      _selectedValue != null;

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
    return CarriagesListBody(
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
