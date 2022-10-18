import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class EditBoltCard extends StatelessWidget {
  final BoltCard? entity;
  const EditBoltCard({this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            title: Text("${entity?.id == null ? "Create" : "Edit"} Bolt Card"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: EditBoltCardForm(
                onSave: () => Navigator.pop(context), entity: entity),
          ),
        )));
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
    return BlocProvider(
        create: ((context) => NFCCubit()),
        child: BlocBuilder<NFCCubit, NFCCubitState>(
            builder: (BuildContext context, NFCCubitState state) {
          var children = <Widget>[
            ReactiveTextField(
              formControlName: 'name',
              decoration: const InputDecoration(
                labelText: 'Card name',
              ),
            ),
          ];
          children.addAll(widget.entity!.Sender != null
              ? [
                  Column(
                    children: [
                      Button(
                        text: state.writing
                            ? 'Hold device to phone'
                            : 'Write to NFC Tag',
                        onPressed: !state.writing
                            ? () {
                                context.read<NFCCubit>().write(Uri.parse(
                                    (widget.entity!.Sender.data as String)
                                        .replaceAll('https://', 'lnurlw://')));
                              }
                            : null,
                      ),
                      state.success
                          ? const Text('Successfully wrote to card')
                          : (state.e != null
                              ? Text(state.e.toString())
                              : Container())
                    ],
                  )
                ]
              : []);
          return CustomForm(
              entity: widget.entity ?? BoltCard.fromJson({'name': ''}),
              onSave: widget.onSave,
              cubit: () => getIt<BoltCardCubit>(),
              formGroup: () => FormGroup(
                  {'name': FormControl<String>(value: widget.entity!.name)}),
              children: children);
        }));
  }
}
