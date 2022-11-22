import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class EditContactPage extends StatelessWidget {
  final Contact entity;
  const EditContactPage({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            title: Text(entity.id == null
                ? AppLocalizations.of(context)!.createContact
                : AppLocalizations.of(context)!.editContact),
          ),
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: EditContactForm(
                onSave: () => Navigator.pop(context), entity: entity),
          ),
        )));
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
              .map((e) => FormGroup({
                    'address': FormControl<String>(
                        value: e.address, validators: [isValidAddressValidator])
                  }))
              .toList(),
          validators: [Validators.minLength(1)])
    });
    super.initState();
  }

  addAddress() {
    addressList.add(FormGroup({
      'address': FormControl<String>(
          value: '',
          validators: [Validators.required, isValidAddressValidator]),
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
            // IconButton(
            //     onPressed: () {
            //       // final index = addressList.controls.indexOf(f);
            //       addressList.remove(f);
            //       // addressList.removeAt(index);
            //     },
            //     icon: const Icon(Icons.delete)),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: ((context) => NFCCubit()),
        child: BlocBuilder<NFCCubit, NFCCubitState>(
            builder: (BuildContext context, NFCCubitState state) {
          return CustomForm<ContactCubit, ContactCubitState, Contact>(
              entity: widget.entity ?? Contact.fromJson({'name': ''}),
              onSave: widget.onSave,
              formGroup: () => f,
              builder: (BuildContext context, state) => Column(children: [
                    ReactiveTextField(
                      formControlName: 'name',
                      decoration: const InputDecoration(
                        labelText: 'Contact name',
                      ),
                    ),
                    const SizedBox(
                      height: padding,
                    ),
                    ReactiveFormArray(
                        formArrayName: 'ContactAddresses',
                        builder: (context, formArray, child) => Column(
                              children: addressList.controls
                                  .map((control) => control as FormGroup)
                                  .map(_buildAddress)
                                  .toList(),
                            )),
                    const SizedBox(
                      height: padding,
                    ),
                    // Button.flat(onPressed: addAddress, text: 'Add Address')
                  ]));
        }));
  }
}
