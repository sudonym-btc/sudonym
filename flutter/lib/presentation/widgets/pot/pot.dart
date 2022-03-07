import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/presentation/widgets/pot/pot_header.dart';
import 'package:sudonym/presentation/widgets/pot/send_receive.dart';
import 'package:sudonym/presentation/widgets/transactions/transactions.dart';

import '../../../injection.dart';

class Pot extends StatelessWidget {
  const Pot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: const [
          PotHeader(),
          SendReceive(),
          Expanded(child: Transactions())
        ]);
  }
}
