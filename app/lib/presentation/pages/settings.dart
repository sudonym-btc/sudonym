import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sudonym/config/config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
          body: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Subheader("Lightning"),
                      // const SizedBox(
                      //   height: padding,
                      // ),
                      CustomForm(
                        cubit: getIt<UserCubit>(),
                        entity: getIt<AuthCubit>().user!,
                        children: [
                          FormBuilderTextField(
                            name: 'lightningAddress',
                            initialValue:
                                getIt<AuthCubit>().user!.lightningAddress,
                            decoration: InputDecoration(
                                hintText: 'satoshi',
                                labelText: AppLocalizations.of(context)!
                                    .lightningAddress,
                                suffixText: '@${getIt<Config>().domain}'),
                            validator: (value) {
                              if (value != null && value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    ])),
            const Expanded(
                child: const Padding(
                    padding: EdgeInsets.all(padding), child: BoltCardList())),
            Button(
              text: "Logout",
              onPressed: (() async {
                await getIt<AuthCubit>().logout();
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
            )
          ]),
        )));
  }
}
