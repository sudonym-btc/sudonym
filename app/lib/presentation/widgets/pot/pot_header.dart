import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/bloc/pot.cubit.dart';
import 'package:sudonym/logic/currency/format-currency.dart';
import 'package:sudonym/presentation/components/typography/subtitle.dart';
import 'package:sudonym/presentation/components/typography/header.dart';

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
            Subtitle(state.entity?.get("name") ?? ""),
            Header(FormatCurrency().format(
                state.entity!.get("currency"), state.entity!.get("balance")))
          ]));
    });
  }
}
