import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

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
                    // const CardSection(),
                    const VertDivider(2),
                    ExpansionTile(
                      textColor: Theme.of(context).primaryColor,
                      iconColor: Theme.of(context).primaryColor,
                      tilePadding: const EdgeInsets.fromLTRB(
                          padding * 2, 0, padding * 2, 0),
                      title: Text(AppLocalizations.of(context)!.appInfo),
                      children: const <Widget>[
                        AboutSection(),
                      ],
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(
                          padding * 2, 0, padding * 2, 0),
                      title: Text(AppLocalizations.of(context)!.logout),
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
    return const CustomPadding(multiplier: 2, child: BoltCardList());
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
  FormGroup g = FormGroup({
    'lightningAddress': FormControl<String>(
        value: getIt<AuthCubit>().user!.lightningAddress,
        validators: [
          Validators.required,
          Validators.minLength(4),
          Validators.maxLength(30),
          Validators.pattern(r'^[a-z0-9_.-]+$',
              validationMessage: 'Must only include characters a-z0-9_.-')
        ]),
  });
  @override
  void initState() {
    g.setErrors({
      'lightningAddress': {'required': true}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
        multiplier: 2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Subheader(AppLocalizations.of(context)!.lightning),
                IconButton(
                    iconSize:
                        Theme.of(context).textTheme.displayMedium!.fontSize,
                    onPressed: () {
                      FlutterClipboard.copy(
                              getIt<AuthCubit>().user!.lightningAddress +
                                  '@${getIt<Config>().domain}')
                          .then((value) {
                        SnackBar snackBar = SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.copiedToClipboard),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    icon: const FaIcon(FontAwesomeIcons.copy))
              ]),
          Info(AppLocalizations.of(context)!.lightningAddressDescription),
          const VertDivider(),
          CustomForm<UserCubit, UserCubitState, User>(
              entity: getIt<AuthCubit>().user!,
              formGroup: () => g,
              builder: (context, state) {
                return Column(
                  children: [
                    ReactiveTextField(
                        formControlName: 'lightningAddress',
                        onEditingComplete: null,
                        autocorrect: false,
                        inputFormatters: [
                          LightningAddressTextFormatter(),
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-z0-9_.-]')),
                        ],
                        validationMessages: {
                          'unique': (error) =>
                              AppLocalizations.of(context)!.nameAlreadyTaken
                        },
                        decoration: InputDecoration(
                            hintText: 'satoshi',
                            labelText: AppLocalizations.of(context)!.address,
                            suffixText: '@${getIt<Config>().domain}')),
                  ],
                );
              })
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
    return CustomPadding(
        multiplier: 2,
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

class LightningAddressTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
