import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class EditPot extends StatelessWidget {
  final Pot? entity;
  const EditPot({this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Text(entity?.id == null
                      ? AppLocalizations.of(context)!.createPot
                      : AppLocalizations.of(context)!.editPot),
                  actions: entity?.id != null && entity?.PotUser.index != 1
                      ? [
                          IconButton(
                              onPressed: () {
                                getIt<PotRepository>().delete(entity!.id);
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              icon: const FaIcon(FontAwesomeIcons.trashCan))
                        ]
                      : [],
                ),
                body: CustomPadding(
                    multiplier: 2,
                    child: EditPotForm(
                        onSave: (p) async => Navigator.pop(context),
                        entity: entity)))));
  }
}

class EditPotForm extends StatefulWidget {
  final Pot? entity;
  final Future<dynamic> Function(dynamic p)? onSave;

  const EditPotForm({required this.entity, this.onSave, Key? key})
      : super(key: key);

  @override
  EditPotFormState createState() {
    return EditPotFormState();
  }
}

class EditPotFormState extends State<EditPotForm> {
  List<String> listOfValue = ['BTC', 'USD', 'GBP'];

  @override
  Widget build(BuildContext context) {
    return CustomForm<PotCubit, PotCubitState, Pot>(
        entity: widget.entity ?? Pot.fromJson({'name': '', 'currency': 'BTC'}),
        onSave: widget.onSave,
        formGroup: () => FormGroup({
              'name': FormControl<String>(
                  value: widget.entity?.name ?? '',
                  validators: [Validators.required, Validators.maxLength(21)]),
              'currency': FormControl<String>(
                  value: widget.entity?.currency ?? 'BTC',
                  validators: [Validators.required])
            }),
        builder: (BuildContext context, state) => Column(
              children: [
                ReactiveTextField(
                  formControlName: 'name',
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.potName,
                  ),
                ),
                const VertDivider(),
                ReactiveDropdownField(
                  formControlName: 'currency',
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.currency,
                  ),
                  hint: Text(AppLocalizations.of(context)!.selectCurrency),
                  items: listOfValue
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Row(children: [
                              Image.asset(
                                'assets/currencies/${currency.toLowerCase()}.png',
                                width: 20,
                                height: 20,
                              ),
                              const HoriDivider(),
                              Text(currency)
                            ]),
                          ))
                      .toList(),
                ),
                const VertDivider(2),
                Info(AppLocalizations.of(context)!.potCurrencyDescription)
              ],
            ));
  }
}
