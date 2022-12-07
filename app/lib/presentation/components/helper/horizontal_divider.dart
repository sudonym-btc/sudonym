import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

class HoriDivider extends StatelessWidget {
  final num multiplier;
  const HoriDivider([this.multiplier = 1]) : super();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: padding * multiplier);
  }
}
