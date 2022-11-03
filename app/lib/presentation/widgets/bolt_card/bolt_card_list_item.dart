import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class BoltCardListItem extends StatelessWidget {
  final BoltCard entity;
  const BoltCardListItem({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => EditBoltCard(
                        entity: entity,
                      )));
        },
        child: ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: Text(entity.name)));
  }
}
