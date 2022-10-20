import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reactive_forms/reactive_forms.dart';
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
                    Button.flat(
                      text: 'Logout',
                      foregroundColor: Colors.red,
                      onPressed: (() async {
                        await getIt<AuthCubit>().logout();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }),
                    ),
                    const AboutSection()
                  ]),
                ))));
  }
}

class CardSection extends StatelessWidget {
  const CardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(padding), child: BoltCardList());
  }
}

class LightningSection extends StatelessWidget {
  const LightningSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Header('Lightning'),
          const SizedBox(
            height: padding,
          ),
          const Info(
              'This is the email address that other wallets that support lightning addresses are able to send money to.'),
          CustomForm(
            cubit: () => getIt<UserCubit>(),
            entity: getIt<AuthCubit>().user!,
            formGroup: () => FormGroup({
              'lightningAddress': FormControl<String>(
                  value: getIt<AuthCubit>().user!.lightningAddress,
                  validators: [
                    Validators.required,
                    Validators.pattern(r'^[A-Za-z0-9_.-]+$')
                  ]),
            }),
            children: [
              ReactiveTextField(
                formControlName: 'lightningAddress',
                decoration: InputDecoration(
                    hintText: 'satoshi',
                    labelText: AppLocalizations.of(context)!.lightningAddress,
                    suffixText: '@${getIt<Config>().domain}'),
              ),
            ],
          )
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
        padding: EdgeInsets.all(padding),
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
