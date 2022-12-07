import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

class VertDivider extends StatelessWidget {
  final int multiplier;
  const VertDivider([this.multiplier = 1]) : super();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: padding * multiplier);
  }
}
