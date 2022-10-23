import 'package:flutter/material.dart' hide ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget loader = const Expanded(
    child: Center(child: CircularProgressIndicator(color: Colors.white)));

class TransactionPage extends StatelessWidget {
  final Transaction? entity;
  const TransactionPage({Key? key, this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<TransactionCubit, TransactionCubitState, Transaction>(
        entity:
            entity ?? ModalRoute.of(context)?.settings.arguments as Transaction,
        builder: ((context, state) {
          if (state.loading || state.entity == null) {
            return StatusPage(
                title: '',
                subtitle: '',
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
        title: (AppLocalizations.of(context)!.paymentPending),
        subtitle: (AppLocalizations.of(context)!.paymentIsCurrentlyInTransit),
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
        title: 'Payment failed',
        subtitle:
            'Outgoing payment of ${FormatCurrency().format(transaction.currencyCode, transaction.amount)} failed to ${transaction.originalAddress}',
        color: Theme.of(context).errorColor);
  }
}

class _OutgoingComplete extends _TransactionStatusPage {
  const _OutgoingComplete({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: AppLocalizations.of(context)!.paymentSent,
        subtitle: AppLocalizations.of(context)!.paymentHasSuccessfullyBeenSent,
        content: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContactSection(transaction),
              SizedBox(
                height: padding * 2,
              ),
              Table(children: [
                TableRow(children: [
                  Text(AppLocalizations.of(context)!.amount),
                  Text(FormatCurrency()
                      .format(transaction.currencyCode, transaction.amount))
                ]),
                TableRow(children: [
                  const Text('Address'),
                  Text(
                    transaction.originalAddress,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
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
        subtitle:
            'Payment of ${FormatCurrency().format(transaction.currencyCode, transaction.amount)} is currently in transit',
        content: loader,
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
        subtitle:
            'Payment of ${FormatCurrency().format(transaction.currencyCode, transaction.amount)} received',
        content: Table(
          children: [
            TableRow(children: [
              Text(AppLocalizations.of(context)!.amount),
              Text(FormatCurrency()
                  .format(transaction.currencyCode, transaction.amount))
            ]),
            TableRow(children: [
              const Text('Address'),
              Text(
                transaction.originalAddress,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
          ],
        ),
        icon: FontAwesomeIcons.check,
        color: Colors.green);
  }
}

class _IncomingFailed extends _TransactionStatusPage {
  const _IncomingFailed({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: 'Payment failed',
        subtitle:
            'Outgoing payment of ${FormatCurrency().format(transaction.currencyCode, transaction.amount)} failed to ${transaction.address}',
        color: Theme.of(context).errorColor);
  }
}

class _ContactSection extends StatelessWidget {
  final Transaction entity;

  const _ContactSection(this.entity);

  @override
  Widget build(BuildContext context) {
    if (entity.ContactAddress?.contactId != null) {
      return ContactListItem(
          contact: Contact.fromJson({'id': entity.ContactAddress.contactId}));
    }
    return ['lnurl', 'lightningaddress'].contains(entity.type)
        ? Button(
            icon: const Icon(Icons.add),
            text: 'Create Contact',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditContact(
                            entity: Contact.fromJson({
                          'ContactAddresses': [
                            {'address': entity.originalAddress}
                          ]
                        })))))
        : Container();
  }
}
