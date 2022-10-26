import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
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
                entity: entity), // onSave: () => Navigator.pop(context),
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
  @override
  Widget build(BuildContext context) {
    return CustomForm<BoltCardCubit, BoltCardCubitState, BoltCard>(
        entity: widget.entity ?? BoltCard.fromJson({'name': ''}),
        onSave: widget.onSave,
        formGroup: () => FormGroup({
              'name': FormControl<String>(
                  value: widget.entity!.name, validators: [Validators.required])
            }),
        builder: (BuildContext context, state) {
          return Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                ReactiveTextField(
                  formControlName: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Card name',
                  ),
                ),
                Expanded(child: WriteToNFCButton(entity: state.entity))
              ]));
        });
  }
}

class WriteToNFCButton extends StatelessWidget {
  final BoltCard? entity;
  const WriteToNFCButton({this.entity, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: entity?.Sender != null
          ? BlocProvider(
              create: ((context) => NFCCubit()),
              child: BlocBuilder<NFCCubit, NFCCubitState>(
                  builder: (BuildContext context, NFCCubitState state) =>
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Button(
                            text: state.writing
                                ? 'Hold device to phone'
                                : 'Write to NFC Tag',
                            onPressed: !state.writing
                                ? () {
                                    context.read<NFCCubit>().write(Uri.parse(
                                        (entity!.Sender.data as String)
                                            .replaceAll(
                                                'https://', 'lnurlw://')));
                                  }
                                : null,
                          ),
                          state.success && !Platform.isIOS
                              ? const Text('Successfully wrote to card')
                              : (state.e != null
                                  ? Text(state.e.toString())
                                  : Container())
                        ],
                      )))
          : Container(),
    );
  }
}
