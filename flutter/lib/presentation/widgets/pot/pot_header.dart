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
    return Container(height: 200, child: Center(child: Text("丰 1,000", style: Theme.of(context).textTheme.headline2,)));
  }
}
