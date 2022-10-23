import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sudonym.models/index.dart' as model;
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

import 'pot_header.dart';
import 'send_receive.dart';

class Pot extends StatelessWidget {
  final model.Pot entity;

  const Pot({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<PotCubit, PotCubitState, model.Pot>(
        entity: entity,
        builder: (BuildContext context, state) {
          List<Widget> children = [
            SlidingUpPanel(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const PotHeader(), SendReceive(entity: entity)],
              ),
              minHeight: 150,
              boxShadow: null,
              panel: TransactionList(pot: entity),
            )
          ];
          if (state.loading) {
            if (state.entity!.name != null) {
              children.add(const LinearProgressIndicator());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }

          return Stack(children: children);
        });
  }
}
