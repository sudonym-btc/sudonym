import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/widgets/bill_split/view_bill_split.dart';
import 'package:sudonym.models/index.dart';

class EditBillSplit extends StatelessWidget {
  final BillSplit entity;
  const EditBillSplit({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entity.id == null) {
      return _EditBillSplit(entity: entity);
    } else {
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
                      multiplier: 2, child: ViewBillSplit(entity: entity!)))));
    }
  }
}

class _EditBillSplit extends StatefulWidget {
  final BillSplit? entity;
  final Future<dynamic> Function(dynamic b)? onSave;

  const _EditBillSplit({required this.entity, this.onSave, Key? key})
      : super(key: key);

  @override
  _EditBillSplitState createState() {
    return _EditBillSplitState();
  }
}

class _EditBillSplitState extends State<_EditBillSplit> {
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
      if (participantCubits.length <= index) return;
      listeningForChanges = false;
      participantCubits[index]
          .setValue(CurrencyInputOutput(value.amount, widget.entity!.currency));
      Future.delayed(
          const Duration(milliseconds: 500), () => listeningForChanges = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.billSplit),
                  actions: [
                    IconButton(
                        onPressed: () {
                          addParticipant(null);
                        },
                        icon: Icon(Icons.person_add))
                  ],
                ),
                body: CustomPadding(
                    multiplier: 2,
                    child: CustomForm<BillSplitCubit, BillSplitCubitState,
                            BillSplit>(
                        entity: widget.entity ??
                            BillSplit.fromJson(
                                {'amount': 0, 'currency': 'BTC'}),
                        beforeSave: (Map<String, dynamic> formData) {
                          return Map<String, dynamic>.from({
                            ...formData,
                            'BillSplitParticipants':
                                formData['BillSplitParticipants']
                                    .map<Map<String, dynamic>>((i) {
                              return Map<String, dynamic>.from(
                                  {...i, 'amount': i['amount'].amount});
                            }).toList()
                          });
                        },
                        onSave: (b) async => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditBillSplit(
                                      entity: b,
                                    ))),
                        formGroup: () => f,
                        builder: (BuildContext context, state) => Expanded(
                                child: Column(
                              children: [
                                const VertDivider(),
                                ReactiveFormArray(
                                    formArrayName: 'BillSplitParticipants',
                                    builder: (context, formArray, child) =>
                                        Expanded(
                                            child: ListView(
                                          children: participantList.controls
                                              .map((control) =>
                                                  control as FormGroup)
                                              .map(_buildParticipant)
                                              .toList(),
                                        ))),
                                const VertDivider(),
                              ],
                            )))))));
  }

  Widget _buildParticipant(FormGroup participantForm) {
    return ReactiveForm(
        formGroup: participantForm,
        child: ListTile(
          contentPadding: EdgeInsets.only(bottom: padding * 2),
          title: Text(getParticipantName(
              participantList.controls.indexOf(participantForm), context)),
          subtitle: CurrencyInput(
            form: participantForm,
            cubit: participantCubits[
                participantList.controls.indexOf(participantForm)],
            large: false,
          ),
        ));
  }

  addParticipant(BillSplitParticipant? part) {
    if (part == null) {
      widget.entity!.BillSplitParticipants
          .add(BillSplitParticipant(null, null));
    }
    participantCubits.add(CurrencyInputCubit(CurrencyInputOptions(
        enabled: participantCubits.isNotEmpty,
        showAltCurrency: true,
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
        if (!changed.contains(i) && listeningForChanges) {
          changed.add(i);
        }
        if (listeningForChanges) {
          calcBillSplit(widget.entity!, i, event.amount, changed);
        }

        removeMax();
        setInputs();
        setMax();
      });
    }
    print(changed);
    calcBillSplit(widget.entity!, null, null, changed);
    setInputs();
    setMax();
    setState(() {});
  }

  setMax() {
    participantCubits.asMap().forEach((key, value) {
      if (key > 0) {
        participantCubits[key].options.min = [
          CurrencyInputOutput(0.00000001, 'BTC')
        ];
      }
      participantCubits[key].options.max = [
        CurrencyInputOutput(
            max(
                (changed.contains(key)
                        ? widget.entity!.BillSplitParticipants[key].amount
                        : 0) +
                    calcAmountLeft(widget.entity, changed),
                0),
            widget.entity!.currency)
      ];
      if (widget.entity!.BillSplitParticipants.length > key) {
        participantCubits[key].enforceConstraints(CurrencyInputOutput(
            widget.entity!.BillSplitParticipants[key].amount,
            widget.entity!.currency));
      }
    });
  }

  removeMax() {
    participantCubits.asMap().forEach((key, value) {
      participantCubits[key].options.max = [];
    });
  }
}

String getParticipantName(int index, BuildContext context) {
  return index == 0
      ? AppLocalizations.of(context)!.you
      : '${AppLocalizations.of(context)!.person} $index';
}
