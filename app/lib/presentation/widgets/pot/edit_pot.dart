import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/bloc/pot.cubit.dart';
import 'package:sudonym/presentation/components/form/form.dart';

class EditPot extends StatelessWidget {
  final Pot? entity;
  const EditPot({this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            bottom: false,
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
        entity: widget.entity ?? Pot.fromJson({}),
        onSave: widget.onSave,
        cubit: getIt<PotCubit>(),
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Pot name',
            ),
            initialValue: widget.entity!.name,
          ),
          FormBuilderDropdown(
            name: 'currency',
            decoration: const InputDecoration(
              labelText: 'Currency',
            ),
            // initialValue: 'Male',
            allowClear: true,
            hint: const Text('Select Currency'),
            items: listOfValue
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text('$currency'),
                    ))
                .toList(),
          )
        ]);
  }
}
