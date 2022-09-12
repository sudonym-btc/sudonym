import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sudonym.models/index.dart' as Model;
import 'package:sudonym/logic/bloc/pot.cubit.dart';
import 'package:sudonym/presentation/widgets/pot/pot_header.dart';
import 'package:sudonym/presentation/widgets/pot/send_receive.dart';
import 'package:sudonym/presentation/widgets/transactions/transaction_list.dart';

import '../../../injection.dart';

class Pot extends StatelessWidget {
  final Model.Pot entity;

  const Pot({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt.get<PotCubit>()..fetch(entity.id))
        ],
        child: BlocBuilder<PotCubit, PotCubitState>(
            builder: (BuildContext context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SlidingUpPanel(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const PotHeader(), SendReceive(entity: entity)],
            ),
            minHeight: 150,
            boxShadow: null,
            panel: TransactionList(pot: entity),
          );
        }));
  }
}
