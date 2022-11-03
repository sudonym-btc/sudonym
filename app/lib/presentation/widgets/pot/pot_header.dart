import 'package:flutter/material.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class PotHeader extends StatelessWidget {
  final Pot entity;
  const PotHeader({
    required this.entity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Subtitle(entity.name ?? ''),
          Header(FormatCurrency().format(entity.currency, entity.balance))
        ]));
  }
}
