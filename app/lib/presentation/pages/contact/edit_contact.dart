import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:reactive_forms/reactive_forms.dart';
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
  late FormGroup f;

  FormArray get addressList => f.control('ContactAddresses') as FormArray;

  @override
  void initState() {
    f = FormGroup({
      'name': FormControl<String>(
          value: widget.entity?.name ?? '', validators: [Validators.required]),
      'ContactAddresses': FormArray(
          widget.entity!.ContactAddresses
              .map((e) =>
                  FormGroup({'address': FormControl<String>(value: e.address)}))
              .toList(),
          validators: [Validators.minLength(1)])
    });
    super.initState();
  }

  addAddress() {
    addressList.add(FormGroup({
      'address':
          FormControl<String>(value: '', validators: [Validators.required]),
    }));
    setState(() {});
  }

  Widget _buildAddress(FormGroup f) {
    return ReactiveForm(
        formGroup: f,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ReactiveTextField(
                // the use of a Key here, is extremely important
                formControlName: 'address',
                decoration: const InputDecoration(
                  labelText: 'Address',
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  // final index = contactAddresses.indexOf(f);
                  // contactAddresses.removeAt(index);
                },
                icon: const Icon(Icons.delete)),
          ],
        ));
  }

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
                labelText: 'Contact name',
              ),
            ),
          ];

          children.add(ReactiveFormArray(
              formArrayName: 'ContactAddresses',
              builder: (context, formArray, child) => Column(
                    children: addressList.controls
                        .map((control) => control as FormGroup)
                        .map(_buildAddress)
                        .toList(),
                  )));

          children.add(Button(onPressed: addAddress, text: 'Add Address'));

          return CustomForm(
              entity: widget.entity ?? Contact.fromJson({'name': ''}),
              onSave: widget.onSave,
              cubit: () => getIt<ContactCubit>(),
              formGroup: () => f,
              children: children);
        }));
  }
}
