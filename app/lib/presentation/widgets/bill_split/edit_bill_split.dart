import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
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
          child: Scaffold(
              appBar: AppBar(
                title: Text(entity?.id == null
                    ? AppLocalizations.of(context)!.billSplit
                    : AppLocalizations.of(context)!.billSplit),
              ),
              body: SafeArea(
                  child: CustomPadding(
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

class BillSplitParticipantController {
  FormGroup control;
  StreamController<dynamic> onInput = StreamController.broadcast();
  CurrencyInputCubit cubit;
  UniqueKey key;
  bool changed = false;
  bool listening = true;
  BillSplitParticipantController(
      this.control, this.cubit, this.key, this.changed) {
    (control.findControl('amount')!.valueChanges
            as Stream<CurrencyInputOutput?>)
        .listen((CurrencyInputOutput? event) {
      print(event);
      if (listening) {
        onInput.add(this);
      }
    });
  }

  listen(bool enabled) {
    listening = enabled;
  }
}

class _EditBillSplitState extends State<_EditBillSplit> {
  late FormGroup f;
  List<BillSplitParticipantController> controllers = [];
  get changed => controllers
      .where((element) => element.changed)
      .map((e) => controllers.indexOf(e))
      .toList();
  StreamController<BillSplitParticipantController> onUpdated =
      StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    calcBillSplit(widget.entity!);

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

    onUpdated.stream.asyncMap((controller) async {
      calcBillSplit(widget.entity!, controllers.indexOf(controller),
          controller.cubit.options.controller!.value.amount, changed);

      controller.changed = true;
      await setInputs(controllers.indexOf(controller));
    }).listen(null);
  }

  stopListening([int? ignore]) {
    // Pause subscriptions for updates
    controllers.asMap().forEach((key, element) {
      if (key != ignore) {
        element.listen(false);
        if (key != ignore) element.cubit.setEnabled(false);
      }
    });
  }

  startListening([int? only]) {
    controllers.asMap().forEach((key, element) {
      if (only != null && key != only) return;
      element.listen(true);
      if (key != 0) element.cubit.setEnabled(true);
    });
  }

  setInputs([int? ignore]) async {
    stopListening();
    removeMax();
    List<Future> updates = [];
    controllers.asMap().forEach((key, value) {
      if (key == ignore) return;
      updates.add(value.cubit.setValue(CurrencyInputOutput(
          widget.entity!.BillSplitParticipants[key].amount,
          widget.entity!.currency)));
    });
    await Future.wait(updates);
    await Future.delayed(new Duration(milliseconds: 10));
    setMax();
    startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
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
            body: SafeArea(
                child: CustomForm<BillSplitCubit, BillSplitCubitState,
                        BillSplit>(
                    entity: widget.entity ??
                        BillSplit.fromJson({'amount': 0, 'currency': 'BTC'}),
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
                    actionBuilder: (BuildContext context, Widget child) =>
                        CustomPadding(multiplier: 2, child: child),
                    builder: (BuildContext context, state) => Expanded(
                            child: Column(
                          children: [
                            ReactiveFormArray(
                                formArrayName: 'BillSplitParticipants',
                                builder: (context, formArray, child) =>
                                    Expanded(
                                        child: ListView(
                                      children: controllers
                                          .map(_buildParticipant)
                                          .toList(),
                                    ))),
                          ],
                        ))))));
  }

  Widget _buildParticipant(BillSplitParticipantController controller) {
    return ReactiveForm(
        key: controller.key, // assign the key

        formGroup: controller.control,
        child: Slidable(
            // Specify a key if the Slidable is dismissible.
            key: const ValueKey(0),

            // The start action pane is the one at the left or the top side.
            startActionPane: controllers.indexOf(controller) > 0 &&
                    widget.entity!.BillSplitParticipants.length > 2
                ? ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const ScrollMotion(),

                    // A pane can dismiss the Slidable.
                    // dismissible: DismissiblePane(onDismissed: () {}),

                    // All actions are defined in the children parameter.
                    children: [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        onPressed: (BuildContext context) async {
                          removeParticipant(controllers.indexOf(controller));
                        },
                        backgroundColor: Theme.of(context).errorColor,
                        foregroundColor: Colors.white,
                        icon: Icons.arrow_left,
                        label: AppLocalizations.of(context)!.remove,
                      ),
                    ],
                  )
                : null,
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                  padding * 2, padding, padding * 2, padding),
              title: Text(
                  getParticipantName(controllers.indexOf(controller), context)),
              subtitle: CurrencyInput(
                form: controller.control,
                cubit: controller.cubit,
                large: false,
              ),
            )));
  }

  removeParticipant(int index) async {
    (f.control('BillSplitParticipants') as FormArray)
        .remove(controllers[index].control);
    controllers.removeAt(index);
    widget.entity!.BillSplitParticipants.removeAt(index);
    setState(() {});
    calcBillSplit(widget.entity!, null, null, changed);
    await setInputs();
  }

  addParticipant(BillSplitParticipant? part) async {
    BillSplitParticipant recalculatedPart;

    if (part == null) {
      widget.entity!.BillSplitParticipants
          .add(BillSplitParticipant(null, null));
      recalculatedPart = widget.entity!.BillSplitParticipants.last;
    } else {
      recalculatedPart = part;
    }
    calcBillSplit(widget.entity!, null, null, changed);

    FormGroup billSplitFormGroup = FormGroup({
      'amount': FormControl<CurrencyInputOutput>(
          value: CurrencyInputOutput(
              recalculatedPart.amount ?? 0, widget.entity!.currency),
          validators: [Validators.required]),
    });

    CurrencyInputCubit c = CurrencyInputCubit(CurrencyInputOptions(
        enabled: controllers.isNotEmpty,
        showAltCurrency: widget.entity!.currency == 'BTC',
        canSwitchCurrency: false,
        max: [
          CurrencyInputOutput(widget.entity!.amount, widget.entity!.currency)
        ],
        initialValue: CurrencyInputOutput(
            recalculatedPart.amount ?? 0, widget.entity!.currency)));
    BillSplitParticipantController controller = BillSplitParticipantController(
        billSplitFormGroup, c, UniqueKey(), false);
    controllers.add(controller);
    (f.control('BillSplitParticipants') as FormArray).add(billSplitFormGroup);

    controller.onInput.stream.listen((data) async {
      onUpdated.add(controller);
    });
    setState(() {});

    await setInputs();
  }

  setMax() async {
    controllers.asMap().forEach((key, value) async {
      if (key > 0) {
        value.cubit.options.min = [CurrencyInputOutput(0.00000001, 'BTC')];
      }
      value.cubit.options.max = [
        CurrencyInputOutput(
            max(
                (value.changed
                        ? widget.entity!.BillSplitParticipants[key].amount
                        : 0) +
                    calcAmountLeft(widget.entity, changed),
                0),
            widget.entity!.currency)
      ];

      setState(
        () {},
      );
      value.cubit
          .enforceConstraints(value.cubit.options.controller!.value)
          .listen((event) {});
    });
  }

  removeMax() {
    for (var value in controllers) {
      value.cubit.options.max = [];
    }
  }
}

String getParticipantName(int index, BuildContext context) {
  return index == 0
      ? AppLocalizations.of(context)!.you
      : '${AppLocalizations.of(context)!.person} $index';
}
