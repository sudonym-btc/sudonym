import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/components/form/form.dart';

class EditBoltCard extends StatelessWidget {
  final BoltCard? entity;
  const EditBoltCard({this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            bottom: false,
            child: Scaffold(
                appBar: AppBar(
                  title: Text(
                      "${entity?.id == null ? "Create" : "Edit"} Bolt Card"),
                ),
                body: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(padding),
                    child: EditBoltCardForm(
                        onSave: () => Navigator.pop(context), entity: entity),
                  ),
                  Expanded(
                      child: Button(
                    text: 'Write NFC',
                    onPressed: () {
                      getIt<NFCCubit>().write(Uri.parse('lnurlw://test.app'));
                    },
                  ))
                ]))));
  }
}

class EditBoltCardForm extends StatefulWidget {
  final BoltCard? entity;
  final Function? onSave;

  const EditBoltCardForm({required this.entity, this.onSave, Key? key})
      : super(key: key);

  @override
  EditBoltCardFormState createState() {
    return EditBoltCardFormState();
  }
}

class EditBoltCardFormState extends State<EditBoltCardForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CustomForm(
        entity: widget.entity ?? BoltCard.fromJson({'name': ''}),
        onSave: widget.onSave,
        cubit: getIt<BoltCardCubit>(),
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Card name',
            ),
            initialValue: widget.entity!.name,
          ),
        ]);
  }
}
