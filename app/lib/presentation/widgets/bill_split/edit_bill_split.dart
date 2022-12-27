import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/bill-split.dart';
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
  List<String> listOfValue = ['BTC', 'USD', 'GBP'];

  @override
  Widget build(BuildContext context) {
    return CustomForm<BillSplitCubit, BillSplitCubitState, BillSplit>(
        entity: widget.entity ??
            BillSplit.fromJson({'name': '', 'currency': 'BTC'}),
        onSave: widget.onSave,
        formGroup: () => FormGroup({
              'amount': FormControl<num>(
                  value: widget.entity?.amount ?? '',
                  validators: [Validators.required, Validators.maxLength(21)]),
              'currency': FormControl<String>(
                  value: widget.entity?.currency ?? 'BTC',
                  validators: [Validators.required])
            }),
        builder: (BuildContext context, state) => Column(
              children: [],
            ));
  }
}
