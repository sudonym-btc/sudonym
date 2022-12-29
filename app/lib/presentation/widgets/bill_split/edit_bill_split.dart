import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class EditBillSplit extends StatelessWidget {
  final BillSplit? entity;
  const EditBillSplit({this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Text(entity?.id == null
                      ? AppLocalizations.of(context)!.billSplit
                      : AppLocalizations.of(context)!.billSplit),
                ),
                body: CustomPadding(
                    multiplier: 2,
                    child: entity?.id == null
                        ? EditBillSplitForm(
                            onSave: (b) async => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditBillSplit(
                                          entity: b,
                                        ))),
                            entity: entity)
                        : Text('New bill split')))));
  }
}

class EditBillSplitForm extends StatefulWidget {
  final BillSplit? entity;
  final Future<dynamic> Function(dynamic b)? onSave;

  const EditBillSplitForm({required this.entity, this.onSave, Key? key})
      : super(key: key);

  @override
  EditBillSplitFormState createState() {
    return EditBillSplitFormState();
  }
}

class EditBillSplitFormState extends State<EditBillSplitForm> {
  late FormGroup f;

  FormArray get participantList =>
      f.control('BillSplitParticipants') as FormArray;
  List<CurrencyInputCubit> participantCubits = [];
  List<int> changed = [];
  bool listeningForChanges = true;

  @override
  void initState() {
    super.initState();
    calcBillSplit(widget.entity!, null, null, changed);

    f = FormGroup({
      'amount': FormControl<num>(
          value: widget.entity?.amount ?? 0, validators: [Validators.required]),
      'currency': FormControl<String>(
          value: widget.entity?.currency ?? 'BTC',
          validators: [Validators.required]),
      'BillSplitParticipants':
          FormArray([], validators: [Validators.minLength(2)])
    });

    widget.entity!.BillSplitParticipants.forEach((el) {
      addParticipant(el);
    });
  }

  setInputs() async {
    widget.entity!.BillSplitParticipants.asMap().forEach((index, value) {
      listeningForChanges = false;
      participantCubits[index]
          .setValue(CurrencyInputOutput(value.amount, widget.entity!.currency));
      Future.delayed(
          const Duration(milliseconds: 10), () => listeningForChanges = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomForm<BillSplitCubit, BillSplitCubitState, BillSplit>(
        entity: widget.entity ??
            BillSplit.fromJson({'amount': 0, 'currency': 'BTC'}),
        beforeSave: (Map<String, dynamic> formData) {
          return Map<String, dynamic>.from({
            ...formData,
            'BillSplitParticipants': formData['BillSplitParticipants']
                .map<Map<String, dynamic>>((i) {
              return Map<String, dynamic>.from(
                  {...i, 'amount': i['amount'].amount});
            }).toList()
          });
        },
        onSave: widget.onSave,
        formGroup: () => f,
        builder: (BuildContext context, state) => Column(
              children: [
                const VertDivider(),
                ReactiveFormArray(
                    formArrayName: 'BillSplitParticipants',
                    builder: (context, formArray, child) => Column(
                          children: participantList.controls
                              .map((control) => control as FormGroup)
                              .map(_buildParticipant)
                              .toList(),
                        )),
                const VertDivider(),
                Button.flat(
                    onPressed: (() => addParticipant(null)), text: 'Add Person')
              ],
            ));
  }

  Widget _buildParticipant(FormGroup participantForm) {
    return ReactiveForm(
        formGroup: participantForm,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(participantList.controls.indexOf(participantForm) == 0
                  ? 'You'
                  : 'Person ${participantList.controls.indexOf(participantForm) + 1}'),
              const VertDivider(),
              CurrencyInput(
                form: participantForm,
                cubit: participantCubits[
                    participantList.controls.indexOf(participantForm)],
                large: false,
              ),
              VertDivider(2)
            ]));
  }

  addParticipant(BillSplitParticipant? part) {
    if (part == null) {
      widget.entity!.BillSplitParticipants
          .add(BillSplitParticipant(null, null));
    }
    participantCubits.add(CurrencyInputCubit(CurrencyInputOptions(
        showAltCurrency: false,
        canSwitchCurrency: false,
        max: [
          CurrencyInputOutput(widget.entity!.amount, widget.entity!.currency)
        ],
        initialValue:
            CurrencyInputOutput(part?.amount ?? 0, widget.entity!.currency))));
    FormGroup f = FormGroup({
      'amount': FormControl<CurrencyInputOutput>(
          value:
              CurrencyInputOutput(part?.amount ?? 0, widget.entity!.currency),
          validators: [Validators.required]),
    });
    participantList.add(f);
    if (participantList.controls.indexOf(f) > 0) {
      f.findControl('amount')!.valueChanges.listen((event) {
        int i = participantList.controls.indexOf(f);
        print(i.toString() +
            ' changed and was listening: ' +
            listeningForChanges.toString());
        if (!changed.contains(i) && listeningForChanges) {
          changed.add(i);
          // print(changed);
          // print(listeningForChanges);
        }
        if (listeningForChanges)
          calcBillSplit(widget.entity!, i, event.amount, changed);
        print(widget.entity!.toJson());

        removeMax();
        setInputs();
        setMax();
      });
    }

    calcBillSplit(widget.entity!, null, null, changed);
    setMax();
    setState(() {});
  }

  setMax() {
    participantCubits.asMap().forEach((key, value) {
      // print('Index-----');
      // print(key);
      // print('Current val');
      // print(widget.entity!.BillSplitParticipants[key].amount);
      // print('Amount unassigned');
      // print(calcAmountLeft(widget.entity, changed));
      // print('Setting max for ' +
      //     key.toString() +
      //     ' to ' +
      //     (widget.entity!.BillSplitParticipants[key].amount +
      //             calcAmountLeft(widget.entity, changed))
      //         .toString());
      participantCubits[key].options.max = [
        CurrencyInputOutput(
            max(
                widget.entity!.BillSplitParticipants[key].amount +
                    calcAmountLeft(widget.entity, changed),
                0),
            widget.entity!.currency)
      ];
      participantCubits[key].enforceConstraints(CurrencyInputOutput(
          widget.entity!.BillSplitParticipants[key].amount,
          widget.entity!.currency));
    });
  }

  removeMax() {
    participantCubits.asMap().forEach((key, value) {
      participantCubits[key].options.max = [];
    });
  }
}
