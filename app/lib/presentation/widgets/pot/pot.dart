import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class PotPage extends StatelessWidget {
  final Pot entity;

  const PotPage({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<PotCubit, PotCubitState, Pot>(
        entity: entity,
        builder: (BuildContext context, state) {
          if (state.loading) {
            if (state.entity!.name != null) {
              // children.add(const LinearProgressIndicator());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
          return LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return WideLayout(
                entity: entity,
              );
            }
            return NarrowLayout(
              entity: entity,
            );
          });
        });
  }
}

class NarrowLayout extends StatelessWidget {
  final Pot entity;
  const NarrowLayout({required this.entity, super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Column(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [PotHeader(entity: entity), SendReceive(entity: entity)],
        ),
        Expanded(child: TransactionList(pot: entity))
        //  SlidingUpPanel(
        //     body: Container(),
        //     minHeight: 150,
        //     boxShadow: null,
        //     panel:
      ])
    ];

    return Stack(children: children);
  }
}

class WideLayout extends StatelessWidget {
  final Pot entity;
  const WideLayout({required this.entity, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PotHeader(
              entity: entity,
            ),
            SendReceive(entity: entity)
          ],
        )),
        Expanded(child: TransactionList(pot: entity))
      ],
    );
  }
}
