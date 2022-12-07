import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

class ButtonBar extends StatelessWidget {
  final List<Widget> children;

  const ButtonBar({required this.children, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    for (var i in children) {
      list.addAll([Expanded(child: i), const HoriDivider()]);
    }
    list.removeLast(); // Pop off last padding

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: list);
  }
}
