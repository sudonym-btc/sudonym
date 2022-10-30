import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/index.dart';
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
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Scaffold(
                appBar:
                    AppBar(title: Text(AppLocalizations.of(context)!.settings)),
                body: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const LightningSection(),
                    const CardSection(),
                    const ExpansionTile(
                      title: Text('App Info'),
                      children: <Widget>[
                        AboutSection(),
                      ],
                    ),
                    ListTile(
                      title: const Text('Logout'),
                      // foregroundColor: Colors.red,
                      onTap: (() async {
                        await getIt<AuthCubit>().logout();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }),
                    ),
                  ]),
                ))));
  }
}

class CardSection extends StatelessWidget {
  const CardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(padding), child: BoltCardList());
  }
}

class LightningSection extends StatefulWidget {
  const LightningSection({super.key});

  @override
  State<StatefulWidget> createState() {
    return LightningSectionState();
  }
}

class LightningSectionState extends State<LightningSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Header('Lightning'),
          const SizedBox(
            height: padding,
          ),
          const Info(
              'This is the email address that other wallets that support lightning addresses are able to send money to.'),
          CustomForm<UserCubit, UserCubitState, User>(
              entity: getIt<AuthCubit>().user!,
              formGroup: () => FormGroup({
                    'lightningAddress': FormControl<String>(
                        value: getIt<AuthCubit>().user!.lightningAddress,
                        validators: [
                          Validators.required,
                          Validators.pattern(r'^[A-Za-z0-9_.-]+$')
                        ]),
                  }),
              builder: (context, state) => Column(
                    children: [
                      ReactiveTextField(
                          formControlName: 'lightningAddress',
                          onEditingComplete: null,
                          decoration: InputDecoration(
                              hintText: 'satoshi',
                              labelText: AppLocalizations.of(context)!
                                  .lightningAddress,
                              suffixText: '@${getIt<Config>().domain}')),
                    ],
                  ))
        ]));
  }
}

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<StatefulWidget> createState() {
    return AboutSectionState();
  }
}

class AboutSectionState extends State<AboutSection> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  initState() {
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        packageName = packageInfo.packageName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(padding),
        child: Table(children: [
          TableRow(children: [
            const TableCell(child: Info('App name')),
            TableCell(child: Info(appName))
          ]),
          TableRow(children: [
            const TableCell(child: Info('Package')),
            TableCell(child: Info(packageName))
          ]),
          TableRow(children: [
            const TableCell(child: Info('Version')),
            TableCell(child: Info(version))
          ]),
          TableRow(children: [
            const TableCell(child: Info('Build')),
            TableCell(child: Info(buildNumber))
          ]),
        ]));
  }
}
