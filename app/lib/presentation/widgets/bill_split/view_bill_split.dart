import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class ViewBillSplit extends StatelessWidget {
  final BillSplit entity;

  const ViewBillSplit({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<BillSplitCubit, BillSplitCubitState, BillSplit>(
        entity: entity,
        builder: (context, state) {
          return state.loading || state.entity == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ...state.entity!.BillSplitParticipants.asMap().entries.map(
                        (p) => BillSplitParticipantListItem(
                            billSplit: state.entity!,
                            entity: p.value,
                            index: p.key)),
                    Expanded(child: Container()),
                    ButtonBar(children: [
                      Button(
                        text: AppLocalizations.of(context)!.ok,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ])
                  ],
                );
        });
  }
}

class BillSplitParticipantListItem extends StatelessWidget {
  final BillSplit billSplit;
  final BillSplitParticipant entity;
  final int index;

  const BillSplitParticipantListItem(
      {super.key,
      required this.entity,
      required this.billSplit,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<BillSplitParticipantCubit,
            BillSplitParticipantCubitState, BillSplitParticipant>(
        entity: entity,
        refreshOnFocus: (state) => true,
        builder: ((context, state) {
          if (state.loading) return Container();
          return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: index > -1
                  ? CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(index.toString()))
                  : null,
              title: Text(getParticipantName(index, context)),
              subtitle: AmountText(
                amount: state.entity!.amount,
                fromCurrency: billSplit.currency,
                toCurrency: billSplit.currency,
                builder: (owedVal) => AmountText(
                    amount: state.entity!.amountPaid,
                    fromCurrency: billSplit.currency,
                    toCurrency: billSplit.currency,
                    builder: (val) => Info(
                        '$owedVal ${AppLocalizations.of(context)!.owed.toLowerCase()} / $val ${AppLocalizations.of(context)!.paid.toLowerCase()}')),
              ),
              trailing: (index > 0 && !state.entity!.paid)
                  ? IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ReceivePage(
                                args: ReceiveOptions(
                                    types: ['lnurl', 'bolt11'],
                                    pot: Pot.fromJson({'id': billSplit.potId}),
                                    onReceive:
                                        (Receiver t, BuildContext context) {
                                      Navigator.of(context).pop();
                                    },
                                    billSplit: billSplit,
                                    amountEnabled: false,
                                    participant: state.entity)),
                            fullscreenDialog: true));
                      },
                      icon: const FaIcon(FontAwesomeIcons.qrcode))
                  : IconButton(
                      icon: const FaIcon(Icons.check),
                      onPressed: (() {}),
                    ));
        }));
  }
}
