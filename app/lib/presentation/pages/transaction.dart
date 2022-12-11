import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Widget loader =
    const Center(child: CircularProgressIndicator(color: Colors.white));

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
                color: Colors.indigo.shade800);
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
        color: Colors.indigo.shade800);
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
          _ContactSection(transaction),
          Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(children: [
                  TableKey(child: Text(AppLocalizations.of(context)!.amount)),
                  AmountText(
                    showLoader: false,
                    amount: transaction.amount,
                    fromCurrency: transaction.currencyCode,
                    toCurrency: transaction.Pot.currency,
                    date: transaction.createdAt,
                  )
                ]),
                ...((transaction.originalAddress != '' &&
                        transaction.originalAddress != null)
                    ? [
                        TableRow(children: [
                          TableKey(
                              child:
                                  Text(AppLocalizations.of(context)!.address)),
                          Text(
                            transaction.originalAddress,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ])
                      ]
                    : []),
                ...((transaction.description != null &&
                        transaction.description != '')
                    ? [
                        TableRow(children: [
                          TableKey(
                              child: Text(
                                  AppLocalizations.of(context)!.description)),
                          Text(transaction.description ?? '')
                        ])
                      ]
                    : []),
                TableRow(children: [
                  TableKey(child: Text(AppLocalizations.of(context)!.time)),
                  Timeago(
                    builder: ((context, value) => Text(timeago.format(
                        transaction.createdAt,
                        locale: Localizations.localeOf(context).toString()))),
                    date: transaction.createdAt,
                  )
                ]),
              ]),
        ]),
        color: Colors.green);
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
            ...(transaction.type == 'onchain'
                ? [
                    ButtonBar(children: [
                      ElevatedButton(
                        style: raisedButtonStyle,
                        onPressed: () async {
                          String url =
                              'https://mempool.space/tx/${transaction.txid}';
                          if (!await launchUrl(Uri.parse(url))) {
                            throw 'Could not launch $url';
                          }
                        },
                        child:
                            Text(AppLocalizations.of(context)!.trackInMempool),
                      )
                    ]),
                    VertDivider()
                  ]
                : []),
            // ButtonBar(children: [
            //   ElevatedButton(
            //     style: raisedButtonStyle,
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //     child: Text(AppLocalizations.of(context)!.ok),
            //   )
            // ])
          ],
        ),
        color: Colors.indigo.shade800);
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
        content: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              TableKey(child: Text(AppLocalizations.of(context)!.amount)),
              AmountText(
                showLoader: false,
                amount: transaction.amount,
                fromCurrency: transaction.currencyCode,
                toCurrency: transaction.Pot.currency,
                date: transaction.createdAt,
              )
            ]),
            ...((transaction.originalAddress != '' &&
                    transaction.originalAddress != null)
                ? [
                    TableRow(children: [
                      TableKey(
                          child: Text(AppLocalizations.of(context)!.address)),
                      Text(
                        transaction.originalAddress ?? '',
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ])
                  ]
                : []),
            ...((transaction.description != null &&
                    transaction.description != '')
                ? [
                    TableRow(children: [
                      TableKey(
                          child:
                              Text(AppLocalizations.of(context)!.description)),
                      Text(transaction.description ?? '')
                    ])
                  ]
                : []),
            TableRow(children: [
              TableKey(child: Text(AppLocalizations.of(context)!.time)),
              Timeago(
                builder: ((context, value) => Text(timeago.format(
                    transaction.createdAt,
                    locale: Localizations.localeOf(context).toString()))),
                date: transaction.createdAt,
              )
            ]),
          ],
        ),
        // actions: ButtonBar(
        //   children: [
        //     ElevatedButton(
        //       style: raisedButtonStyle.copyWith(
        //           backgroundColor: MaterialStatePropertyAll(
        //               Color.fromARGB(20, 255, 255, 255)),
        //           foregroundColor: MaterialStatePropertyAll(
        //               Color.fromARGB(200, 255, 255, 255)),
        //           side: MaterialStatePropertyAll(BorderSide.merge(
        //               BorderSide(color: Colors.white.withAlpha(100), width: 1),
        //               BorderSide(
        //                   color: Colors.white.withAlpha(100), width: 1)))),
        //       onPressed: () {
        //         Navigator.of(context).pop();
        //       },
        //       child: Text(AppLocalizations.of(context)!.ok),
        //     )
        //   ],
        // ),
        color: Colors.green);
  }
}

class TableKey extends StatelessWidget {
  final Widget child;
  const TableKey({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: 0.8,
        child: Padding(
          padding: EdgeInsets.only(
              right: padding, bottom: padding / 4, top: padding / 4),
          child: child,
        ));
  }
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
      return Column(children: [
        ContactListItem(
            actions: false,
            fetch: true,
            contact: Contact.fromJson({'id': entity.ContactAddress.contactId})),
        const VertDivider(2),
      ]);
    }
    return ['lightningaddress'].contains(entity.type)
        ? Column(children: [
            Button(
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
                            }))))),
            const VertDivider(2),
          ])
        : Container();
  }
}
