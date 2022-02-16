import 'package:flutter/material.dart';

class LayoutController extends StatelessWidget {
  const LayoutController({
    Key? key,
    required this.webLayout,
    required this.mobileLayout,
  }) : super(key: key);

  final Widget webLayout;
  final Widget mobileLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 750 || constraints.maxHeight < 600) {
        return mobileLayout;
      } else {
        return webLayout;
      }
    });
  }
}
