import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';
import 'package:sudonym/logic/bloc/user.cubit.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/components/form/form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/pot/edit_pot.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: Scaffold(
                appBar:
                    AppBar(title: Text(AppLocalizations.of(context)!.settings)),
                body: Container(
                  padding: const EdgeInsets.all(padding),
                  child: Column(children: [
                    CustomForm(
                      cubit: getIt<UserCubit>(),
                      entity: getIt<AuthCubit>().user!,
                      children: [
                        FormBuilderTextField(
                          name: 'lightningAddress',
                          initialValue:
                              getIt<AuthCubit>().user!.lightningAddress,
                          decoration: InputDecoration(
                              hintText: 'e.g. satoshi',
                              labelText: AppLocalizations.of(context)!
                                  .lightningAddress,
                              suffixText: '@sudonym.app'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Button(
                        text: 'Add Pot',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditPot(
                                          entity: Pot.fromJson({
                                        'name': '',
                                        'currency': 'BTC',
                                        'spendableBalance': 0,
                                        'balance': 0
                                      }))));
                        }),
                  ]),
                ))));
  }
}
