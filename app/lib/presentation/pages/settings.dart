import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sudonym/config/config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Column(mainAxisSize: MainAxisSize.min, children: [
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
    ));
  }
}

class CardSection extends StatelessWidget {
  const CardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
        child:
            Padding(padding: EdgeInsets.all(padding), child: BoltCardList()));
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
            children: [
              FormBuilderTextField(
                name: 'lightningAddress',
                initialValue: getIt<AuthCubit>().user!.lightningAddress,
                decoration: InputDecoration(
                    hintText: 'satoshi',
                    labelText: AppLocalizations.of(context)!.lightningAddress,
                    suffixText: '@${getIt<Config>().domain}'),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (!RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(value ?? '')) {
                    return 'Cannot contain symbols';
                  }
                  return null;
                },
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
    return Table(children: [
      TableRow(children: [
        const TableCell(child: Text('App name')),
        TableCell(child: Text(appName))
      ]),
      TableRow(children: [
        const TableCell(child: Text('Package')),
        TableCell(child: Text(packageName))
      ]),
      TableRow(children: [
        const TableCell(child: Text('Version')),
        TableCell(child: Text(version))
      ]),
      TableRow(children: [
        const TableCell(child: Text('Build')),
        TableCell(child: Text(buildNumber))
      ]),
    ]);
  }
}
