import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Widget loader = const Center(child: CircularProgressIndicator());

class TransactionPage extends StatelessWidget {
  final Transaction? entity;
  const TransactionPage({Key? key, this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<TransactionCubit, TransactionCubitState, Transaction>(
        entity:
            entity ?? ModalRoute.of(context)?.settings.arguments as Transaction,
        refresh: (state) =>
            state.entity?.status ==
            null, // Keep refreshing if null as websockets might fail on bad connection
        builder: ((context, state) {
          if (state.loading && state.entity == null) {
            return StatusPage(
                title: null,
                subtitle: null,
                content: loader,
                color: loadingColor);
          } else if (state.entity!.outgoing) {
            if (state.entity!.status == true) {
              return _OutgoingComplete(transaction: state.entity!);
            } else if (state.entity!.status == null) {
              return _OutgoingPending(transaction: state.entity!);
            } else {
              return _OutgoingFailed(transaction: state.entity!);
            }
          } else {
            if (state.entity!.status == true) {
              return _IncomingComplete(transaction: state.entity!);
            } else if (state.entity!.status == null) {
              return _IncomingPending(transaction: state.entity!);
            } else {
              return _IncomingFailed(transaction: state.entity!);
            }
          }
        }));
  }
}

abstract class _TransactionStatusPage extends StatelessWidget {
  final Transaction transaction;
  const _TransactionStatusPage({Key? key, required this.transaction})
      : super(key: key);
}

class _OutgoingPending extends _TransactionStatusPage {
  const _OutgoingPending({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: (AppLocalizations.of(context)!.paymentInProgress),
        subtitle: AmountText(
            showLoader: false,
            fromCurrency: transaction.currencyCode,
            amount: transaction.amount,
            toCurrency: transaction.Pot.currency,
            date: transaction.createdAt,
            builder: (val) => Subtitle(AppLocalizations.of(context)!
                .paymentIsCurrentlyInTransit(val))),
        content: loader,
        color: loadingColor);
  }
}

class _OutgoingFailed extends _TransactionStatusPage {
  const _OutgoingFailed({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: AppLocalizations.of(context)!.paymentError,
        subtitle: AmountText(
            showLoader: false,
            fromCurrency: transaction.currencyCode,
            amount: transaction.amount,
            toCurrency: transaction.Pot.currency,
            date: transaction.createdAt,
            builder: (val) => Subtitle(AppLocalizations.of(context)!
                .outgoingPaymentError(
                    val, replaceLongAddress(transaction.originalAddress)))),
        content: Text(transaction.errorMessage ?? ''),
        actions: ButtonBar(children: [
          Button(
              onPressed: () => Navigator.of(context).pop(),
              text: AppLocalizations.of(context)!.ok)
        ]),
        color: Theme.of(context).errorColor);
  }
}

var replaceLongAddress = (String input, [int maxLength = 21]) {
  if (input.length > maxLength) {
    return '${input.substring(0, maxLength)}...';
  }
  return input;
};

class _OutgoingComplete extends _TransactionStatusPage {
  const _OutgoingComplete({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    bool shouldDisplayContact = transaction.contactAddressId != null ||
        ['lightningaddress'].contains(transaction.type);
    bool shouldDisplaySplitBill = transaction.outgoing;

    return StatusPage(
        title: AppLocalizations.of(context)!.paymentSent,
        subtitle: AmountText(
            showLoader: false,
            fromCurrency: transaction.currencyCode,
            amount: transaction.amount,
            toCurrency: transaction.Pot.currency,
            date: transaction.createdAt,
            builder: (val) => Subtitle(
                AppLocalizations.of(context)!.paymentOutgoingSuccess(val))),
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (shouldDisplayContact) ...[
              _ContactSection(transaction),
              VertDivider()
            ],
            if (shouldDisplaySplitBill) _SplitBillSection(transaction)
          ]),
          VertDivider(2),
          _TransactionInfo(transaction)
        ]),
        actions: ButtonBar(children: [
          Button(
              onPressed: () => Navigator.of(context).pop(),
              text: AppLocalizations.of(context)!.ok)
        ]),
        color: successColor);
  }
}

class _IncomingPending extends _TransactionStatusPage {
  const _IncomingPending({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: AppLocalizations.of(context)!.paymentIncoming,
        subtitle: AmountText(
            showLoader: false,
            fromCurrency: transaction.currencyCode,
            amount: transaction.amount,
            toCurrency: transaction.Pot.currency,
            date: transaction.createdAt,
            builder: (val) => Subtitle(AppLocalizations.of(context)!
                .paymentIsCurrentlyInTransit(val))),
        content: loader,
        actions: Column(
          children: [
            if (transaction.type == 'onchain') ...[
              ButtonBar(children: [
                Button(
                  onPressed: () async {
                    String url = 'https://mempool.space/tx/${transaction.txid}';
                    if (!await launchUrl(Uri.parse(url))) {
                      throw 'Could not launch $url';
                    }
                  },
                  text: AppLocalizations.of(context)!.trackInMempool,
                ),
              ]),
              const VertDivider()
            ],
            ButtonBar(children: [
              Button(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: AppLocalizations.of(context)!.ok,
              )
            ])
          ],
        ),
        color: loadingColor);
  }
}

class _IncomingComplete extends _TransactionStatusPage {
  const _IncomingComplete({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: AppLocalizations.of(context)!.paymentReceived,
        subtitle: AmountText(
            showLoader: false,
            fromCurrency: transaction.currencyCode,
            amount: transaction.amount,
            toCurrency: transaction.Pot.currency,
            date: transaction.createdAt,
            builder: (val) => Subtitle(
                AppLocalizations.of(context)!.incomingPaymentSuccess(val))),
        content: _TransactionInfo(transaction),
        actions: ButtonBar(children: [
          Button(
              onPressed: () => Navigator.of(context).pop(),
              text: AppLocalizations.of(context)!.ok)
        ]),
        color: successColor);
  }
}

TableRow getRow(Widget left, Widget right) {
  return TableRow(children: [
    Padding(
        padding: EdgeInsets.only(
            right: padding * 2, bottom: padding / 4, top: padding / 4),
        child: left),
    Padding(
        padding: EdgeInsets.only(bottom: padding / 4, top: padding / 4),
        child: right)
  ]);
}

class _IncomingFailed extends _TransactionStatusPage {
  const _IncomingFailed({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: AppLocalizations.of(context)!.paymentError,
        subtitle: AmountText(
            showLoader: false,
            fromCurrency: transaction.currencyCode,
            amount: transaction.amount,
            toCurrency: transaction.Pot.currency,
            builder: (val) => Subtitle(AppLocalizations.of(context)!
                .incomingPaymentError(val, transaction.address))),
        color: Theme.of(context).errorColor);
  }
}

class _ContactSection extends StatelessWidget {
  final Transaction entity;

  const _ContactSection(this.entity);

  @override
  Widget build(BuildContext context) {
    if (entity.ContactAddress?.contactId != null) {
      return Button(
          icon: const Icon(Icons.person),
          text: entity.ContactAddress.address,
          onPressed: () {});

      //               Column(children: [
      // ContactListItem(
      //     actions: false,
      //     fetch: true,
      //     contact: Contact.fromJson({'id': entity.ContactAddress.contactId}))
      // ]);
    } else if (['lightningaddress'].contains(entity.type)) {
      return Button(
          icon: const Icon(Icons.add),
          text: AppLocalizations.of(context)!.createContact,
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditContactPage(
                          entity: Contact.fromJson({
                        'ContactAddresses': [
                          {'address': entity.originalAddress}
                        ]
                      })))));
    }
    return Container();
  }
}

class _SplitBillSection extends StatelessWidget {
  final Transaction entity;

  const _SplitBillSection(this.entity);

  @override
  Widget build(BuildContext context) {
    return Button(
        icon: entity.billSplitId != null
            ? const Icon(Icons.arrow_right)
            : const Icon(Icons.add),
        text: entity.billSplitId != null
            ? AppLocalizations.of(context)!.viewBillSplit
            : AppLocalizations.of(context)!.billSplit,
        onPressed: () async {
          var amount = await getIt<CurrencyRepository>().getRate(
              fromCurrency: entity.currencyCode,
              toCurrency: entity.Pot.currency,
              amount: entity.amount);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditBillSplit(
                      entity: entity.billSplitId != null
                          ? BillSplit.fromJson({
                              'id': entity.billSplitId,
                              'amount': amount.amount,
                              'currency': entity.Pot.currency
                            })
                          : BillSplit.fromJson({
                              'potId': entity.potId,
                              'BillSplitParticipants': [
                                {'amount': 0},
                                {'amount': 0}
                              ],
                              'transactionId': entity.id,
                              'amount': amount.amount,
                              'currency': entity.Pot.currency
                            }))));
        });
  }
}

class _TransactionInfo extends StatelessWidget {
  final Transaction transaction;
  const _TransactionInfo(this.transaction);
  @override
  Widget build(BuildContext context) {
    return Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          getRow(
              Subtitle(AppLocalizations.of(context)!.amount),
              Row(children: [
                AmountText(
                  showLoader: false,
                  amount: transaction.amount,
                  fromCurrency: transaction.currencyCode,
                  toCurrency: transaction.Pot.currency,
                  date: transaction.createdAt,
                ),
                if (transaction.Pot.currency == 'BTC')
                  AmountText(
                    showLoader: false,
                    amount: transaction.amount,
                    fromCurrency: transaction.currencyCode,
                    toCurrency: 'USD',
                    date: transaction.createdAt,
                    builder: (val) => Text(' ($val)'),
                  )
              ])),
          if (transaction.originalAddress != '' &&
              transaction.originalAddress != null)
            getRow(
                Subtitle(AppLocalizations.of(context)!.address),
                Text(
                  transaction.originalAddress,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          if (transaction.description != null && transaction.description != '')
            getRow(Subtitle(AppLocalizations.of(context)!.description),
                Text(transaction.description)),
          if (transaction.comment != null && transaction.comment != '')
            getRow(Subtitle(AppLocalizations.of(context)!.comment),
                Text(transaction.comment!)),
          getRow(
              Subtitle(AppLocalizations.of(context)!.time),
              Timeago(
                builder: ((context, value) => Text(timeago.format(
                    transaction.createdAt,
                    locale: Localizations.localeOf(context).toString()))),
                date: transaction.createdAt,
              )),
        ]);
  }
}
