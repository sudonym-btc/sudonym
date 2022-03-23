import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/pot.cubit.dart';

import '../../../logic/currency/btc_formatter.dart';

class PotHeader extends StatelessWidget {
  const PotHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PotCubit, PotCubitState>(
        builder: (BuildContext context, state) {
      return Container(
          margin: const EdgeInsets.only(top: 0.0, bottom: 30.0),
          child: Column(
              children: [
                Text(
                  state.entity?.name ?? "",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  formatBTC(state.entity?.balance as num),
                  style: Theme.of(context).textTheme.headline3,
                )
              ]));
    });
  }
}
