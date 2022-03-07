import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';

import '../../../injection.dart';
import '../../pages/home_page.dart';
import '../../pages/signin.dart';

class PotHeader extends StatelessWidget {
  const PotHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 30.0, bottom: 30.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.ce,
          children: [
          Text(
            "Your balance",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            "1,090 sats",
            style: Theme.of(context).textTheme.headline3,
          )
        ]));
  }
}
