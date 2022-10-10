import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/logic/index.dart';

class PotHeader extends StatelessWidget {
  const PotHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PotCubit, PotCubitState>(
        builder: (BuildContext context, state) {
      return Padding(
          padding: const EdgeInsets.all(padding * 2),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Subtitle(state.entity?.name ?? ''),
            Header(FormatCurrency()
                .format(state.entity!.currency, state.entity!.balance))
          ]));
    });
  }
}
