import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

class CustomPadding extends StatelessWidget {
  final num? multiplierWidth;
  final num? multiplierHeight;
  final num multiplier;
  final Widget child;
  const CustomPadding(
      {super.key,
      required this.child,
      this.multiplier = 1,
      this.multiplierHeight,
      this.multiplierWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(
            padding * (multiplierWidth ?? multiplier),
            padding * (multiplierHeight ?? multiplier),
            padding * (multiplierWidth ?? multiplier),
            padding * (multiplierHeight ?? multiplier)),
        child: child);
  }
}
