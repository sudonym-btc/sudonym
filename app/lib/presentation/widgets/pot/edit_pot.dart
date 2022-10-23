import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart' hide PotPage;

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
                  title: Text("${entity?.id == null ? "Create" : "Edit"} Pot"),
                ),
                body: Padding(
                    padding: const EdgeInsets.all(padding),
                    child: EditPotForm(
                        onSave: () => Navigator.pop(context),
                        entity: entity)))));
  }
}

class EditPotForm extends StatefulWidget {
  final Pot? entity;
  final Function? onSave;

  const EditPotForm({required this.entity, this.onSave, Key? key})
      : super(key: key);

  @override
  EditPotFormState createState() {
    return EditPotFormState();
  }
}

class EditPotFormState extends State<EditPotForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> listOfValue = ['BTC', 'USD', 'GBP'];

  @override
  Widget build(BuildContext context) {
    return CustomForm(
        entity: widget.entity ?? Pot.fromJson({'name': '', 'currency': 'BTC'}),
        onSave: widget.onSave,
        cubit: () => getIt<PotCubit>(),
        formGroup: () => FormGroup({
              'name': FormControl<String>(
                  value: widget.entity?.name ?? '',
                  validators: [Validators.required]),
              'currency': FormControl<String>(
                  value: widget.entity?.currency ?? 'BTC',
                  validators: [Validators.required])
            }),
        children: [
          Column(
            children: [
              ReactiveTextField(
                formControlName: 'name',
                decoration: const InputDecoration(
                  labelText: 'Pot name',
                ),
              ),
              ReactiveDropdownField(
                formControlName: 'currency',
                decoration: const InputDecoration(
                  labelText: 'Currency',
                ),
                hint: const Text('Select Currency'),
                items: listOfValue
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Row(children: [Text(currency)]),
                        ))
                    .toList(),
              )
            ],
          )
        ]);
  }
}
