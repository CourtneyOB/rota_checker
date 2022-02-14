import 'package:flutter/material.dart';

class LayoutController extends StatelessWidget {
  const LayoutController(
      {Key? key,
      required this.webLayout,
      required this.mobileLayout,
      required this.unableToView})
      : super(key: key);

  final Widget webLayout;
  final Widget mobileLayout;
  final Widget unableToView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxHeight < 550) {
        return unableToView;
      }
      if (constraints.maxWidth < 750 || constraints.maxHeight < 600) {
        return mobileLayout;
      } else {
        return webLayout;
      }
    });
  }
}
