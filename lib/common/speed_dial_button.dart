import 'package:flutter/material.dart';

import 'floating_action_button.dart';

class SpeedDialButtonItem {
  final Widget label;
  final Widget? icon;
  final VoidCallback onPressed;

  SpeedDialButtonItem(
      {required this.label, this.icon, required this.onPressed});
}

class SpeedDialButton extends StatelessWidget {
  final Widget? icon;
  final Widget label;
  final Color? backgroundColor;
  final List<SpeedDialButtonItem> items;

  SpeedDialButton(
      {this.icon,
      required this.label,
      this.backgroundColor,
      required this.items});

  Widget build(BuildContext context) {
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: icon,
        label: label,
        backgroundColor: backgroundColor,
        onPressed: () {
          Navigator.of(context).push(_SpeedDialPopupRoute(
              items: items,
              buttonBackgroundColor: backgroundColor,
              barrierLabel:
                  MaterialLocalizations.of(context).modalBarrierDismissLabel));
        },
      ),
    );
  }
}

class _SpeedDialPopupRoute extends PopupRoute<void> {
  final List<SpeedDialButtonItem> items;
  final Color? buttonBackgroundColor;

  _SpeedDialPopupRoute(
      {required this.items, this.buttonBackgroundColor, String? barrierLabel})
      : _barrierLabel = barrierLabel;

  @override
  Color get barrierColor => Colors.black54;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => _barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(items.length, (int index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: _buildItemButton(context, item, index),
        );
      })
        ..add(Container(
          margin: EdgeInsets.only(bottom: 16),
          child: buildFloatingActionButtonContainer(child: Container()),
        )),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  final String? _barrierLabel;

  Widget _buildItemButton(
      BuildContext context, SpeedDialButtonItem item, int index) {
    return buildFloatingActionButtonContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildTransition(
            GestureDetector(
              child: _buildLabelContainer(
                child: item.label,
              ),
              onTap: () => itemSelected(context, item),
            ),
            animation!,
            index,
          ),
          _buildTransition(
            Container(
              width: floatingActionButtonHeight,
              height: floatingActionButtonHeight,
              child: FloatingActionButton(
                heroTag: null,
                mini: true,
                backgroundColor: buttonBackgroundColor,
                child: item.icon,
                onPressed: () => itemSelected(context, item),
              ),
            ),
            animation!,
            index,
          ),
        ],
      ),
    );
  }

  Widget _buildTransition(
      Widget child, Animation<double> animation, int index) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Interval(0.0, 1.0 - index / items.length / 2.0,
            curve: Curves.easeOut),
      ),
      child: child,
    );
  }

  Widget _buildLabelContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      margin: EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(5, 5),
            blurRadius: 5,
          )
        ],
      ),
      child: DefaultTextStyle(
          style: TextStyle(fontSize: 14, color: Colors.black), child: child),
    );
  }

  void itemSelected(BuildContext context, SpeedDialButtonItem item) {
    Navigator.of(context).pop();
    item.onPressed();
  }
}
