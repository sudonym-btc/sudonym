import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/pot/pot.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          bottom: false,
            child: Scaffold(
          appBar: AppBar(actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: FaIcon(FontAwesomeIcons.cog, size: 14),
            )
          ]),
          body: Pot(potId: 1),
        )));
  }
}
