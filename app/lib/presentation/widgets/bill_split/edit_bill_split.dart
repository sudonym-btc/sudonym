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
                    child: EditBillSplitForm(
                        onSave: () => Navigator.pop(context),
                        entity: entity)))));
  }
}

class EditBillSplitForm extends StatefulWidget {
  final BillSplit? entity;
  final Function? onSave;

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

  @override
  void initState() {
    super.initState();

    f = FormGroup({
      'amount': FormControl<num>(
          value: widget.entity?.amount ?? 0, validators: [Validators.required]),
      'currency': FormControl<String>(
          value: widget.entity?.currency ?? 'BTC',
          validators: [Validators.required]),
      'BillSplitParticipants': FormArray(
          (widget.entity!.BillSplitParticipants
              .map<AbstractControl<dynamic>>((e) => FormGroup({
                    'amount': FormControl<CurrencyInputOutput>(
                        value: CurrencyInputOutput(
                            e.amount, widget.entity!.currency),
                        validators: [])
                  }))).toList(),
          validators: [Validators.minLength(2)])
    });

    recalc();

    participantList.controls.forEach((element) {
      element.findControl('amount')!.valueChanges.listen((event) {
        int i = participantList.controls.indexOf(element);
        widget.entity!.BillSplitParticipants[i].amount = event.amount;
        recalc(widget.entity!.BillSplitParticipants[i],
            [widget.entity!.BillSplitParticipants[i]]);
        print(event);
      });
    });

    // participantList.valueChanges.listen((event) {
    //   print(event);
    // });
  }

  recalc([BillSplitParticipant? update, List<BillSplitParticipant>? changed]) {
    if (widget.entity!.id == null) {
      calcBillSplit(widget.entity!, update, changed ?? []);
      // widget.entity!.BillSplitParticipants.asMap().forEach((index, value) {
      //   participantList
      //       .controls[widget.entity!.BillSplitParticipants.indexOf(value)]
      //       .findControl('amount')!
      //       .updateValue(
      //           CurrencyInputOutput(value.amount, widget.entity!.currency));
      // });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomForm<BillSplitCubit, BillSplitCubitState, BillSplit>(
        entity: widget.entity ??
            BillSplit.fromJson({'amount': 0, 'currency': 'BTC'}),
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
                Button.flat(onPressed: addParticipant, text: 'Add Person')
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
                onChanged: ((p0) {
                  print(p0);
                }),
                options: CurrencyInputOptions(
                    showAltCurrency: false,
                    canSwitchCurrency: false,
                    max: [
                      CurrencyInputOutput(
                          widget.entity!.amount, widget.entity!.currency)
                    ],
                    initialValue: participantForm.control('amount').value),
                large: false,
              ),
              VertDivider(2)
            ]));
  }

  addParticipant() {
    participantList.add(FormGroup({
      'amount': FormControl<CurrencyInputOutput>(
          value: CurrencyInputOutput(0, widget.entity!.currency),
          validators: [Validators.required]),
    }));
    recalc();
    setState(() {});
  }
}
