import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/widgets/pot/pot_settings/edit_pot/edit_pot.dart';

class EditPot extends StatelessWidget {
  const EditPot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pot'), actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          icon: const FaIcon(FontAwesomeIcons.gear, size: 14),
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: Column(
          children: const [
            EditPotName(),
            SizedBox(
              height: 50,
            ),
            DropDownCurrencyMenu(),
            SizedBox(
              height: 50,
            ),
            SaveChanges()
          ],
        ),
      ),
    );
  }
}
