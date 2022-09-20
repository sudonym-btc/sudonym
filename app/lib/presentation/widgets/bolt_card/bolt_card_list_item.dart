import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/presentation/widgets/pot/pot_settings/credit_card/creditcard.dart';

class BoltCardListItem extends StatelessWidget {
  BoltCard entity;

  BoltCardListItem({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/contact');
        },
        child: Container(
            padding: const EdgeInsets.all(padding), child: CreditCard()));
  }
}
