import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class EditContact extends StatelessWidget {
  final Contact entity;
  const EditContact({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${entity.id == null ? "Create" : "Edit"} Contact"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: EditContactForm(
                onSave: () => Navigator.pop(context), entity: entity),
          ),
        ));
  }
}

class EditContactForm extends StatefulWidget {
  final Contact? entity;
  final Function? onSave;

  const EditContactForm({required this.entity, this.onSave, Key? key})
      : super(key: key);

  @override
  EditContactFormState createState() {
    return EditContactFormState();
  }
}

class EditContactFormState extends State<EditContactForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: ((context) => NFCCubit()),
        child: BlocBuilder<NFCCubit, NFCCubitState>(
            builder: (BuildContext context, NFCCubitState state) {
          var children = <Widget>[
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(
                labelText: 'Contact name',
              ),
              initialValue: widget.entity?.name ?? '',
            ),
          ];

          children.addAll(widget.entity!.ContactAddresses.map(
            (e) => FormBuilderTextField(
              name: widget.entity!.ContactAddresses.indexOf(e).toString(),
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
              initialValue: e.address ?? '',
            ),
          ));

          return CustomForm(
              entity: widget.entity ?? Contact.fromJson({'name': ''}),
              onSave: widget.onSave,
              cubit: () => getIt<ContactCubit>(),
              children: children);
        }));
  }
}
