import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/pot.cubit.dart';
import 'package:sudonym/presentation/widgets/pot/pot_header.dart';
import 'package:sudonym/presentation/widgets/pot/send_receive.dart';
import 'package:sudonym/presentation/widgets/transactions/transactions.dart';

import '../../../injection.dart';

class Pot extends StatelessWidget {
  final num potId;
  const Pot({required this.potId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<PotCubit>())],
        child: BlocBuilder<PotCubit, PotCubitState>(
            builder: (BuildContext context, state) {
          if (state.loading) {
            return Center(child: const CircularProgressIndicator());
          }
          return Column(children: [
            const PotHeader(),
            SendReceive(potId: potId),
            const Expanded(child: Transactions())
          ]);
        }));
  }
}
