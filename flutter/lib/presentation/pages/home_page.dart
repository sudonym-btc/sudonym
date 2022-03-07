import 'package:flutter/material.dart';

import '../widgets/pot/pot.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: const SafeArea(
            child: Scaffold(
          body: Pot(),
        )));
  }
}
