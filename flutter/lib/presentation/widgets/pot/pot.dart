import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';
import 'package:sudonym/presentation/widgets/pot/pot_header.dart';
import 'package:sudonym/presentation/widgets/transactions/transactions.dart';

import '../../../injection.dart';
import '../../pages/home_page.dart';
import '../../pages/signin.dart';

class Pot extends StatelessWidget {
  const Pot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [PotHeader(), Transactions()]));
  }
}
