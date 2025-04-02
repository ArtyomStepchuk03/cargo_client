import 'package:flutter/material.dart';

class SplitWidget extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;

  SplitWidget({required this.leftChild, required this.rightChild});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: leftChild,
          ),
          Expanded(
            child: Material(
              elevation: 4.0,
              child: rightChild,
            ),
          ),
        ],
      ),
    );
  }
}
