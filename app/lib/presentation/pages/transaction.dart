import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/transaction.cubit.dart';
import 'package:sudonym/logic/currency/format-currency.dart';
import 'package:sudonym/presentation/widgets/status_page/status_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../injection.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => TransactionCubit(getIt<TransactionRepository>())
                ..fetch(
                    (ModalRoute.of(context)?.settings.arguments as Transaction)
                        .get("id")))
        ],
        child: BlocBuilder<TransactionCubit, TransactionCubitState>(
            builder: ((context, state) {
          if (state.entity == null) {
            return StatusPage(
                title: "",
                subtitle: "",
                content: Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                color: Colors.indigo.shade800);
          } else if (state.entity!.get("outgoing")) {
            if (state.entity!.get("status") == true) {
              return _OutgoingComplete(transaction: state.entity!);
            } else if (state.entity!.get("status") == null) {
              return _OutgoingPending(transaction: state.entity!);
            } else {
              return _OutgoingFailed(transaction: state.entity!);
            }
          } else {
            if (state.entity!.get("status") == true) {
              return _IncomingComplete(transaction: state.entity!);
            } else if (state.entity!.get("status") == null) {
              return _IncomingPending(transaction: state.entity!);
            } else {
              return _IncomingFailed(transaction: state.entity!);
            }
          }
        })));
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
        content: Center(child: CircularProgressIndicator(color: Colors.white)),
        color: Colors.indigo.shade800);
  }
}

class _OutgoingFailed extends _TransactionStatusPage {
  const _OutgoingFailed({required Transaction transaction})
      : super(transaction: transaction);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: "Payment failed",
        subtitle: "Outgoing payment of " +
            FormatCurrency().format(
                transaction.get("currencyCode"), transaction.get("amount")) +
            " failed to " +
            transaction.get("originalAddress"),
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
        icon: FontAwesomeIcons.check,
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
        subtitle: "Payment of " +
            FormatCurrency().format(
                transaction.get("currencyCode"), transaction.get("amount")) +
            " is currently in transit",
        content: Center(child: CircularProgressIndicator(color: Colors.white)),
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
        subtitle: "Payment of " +
            FormatCurrency().format(
                transaction.get("currencyCode"), transaction.get("amount")) +
            " received",
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
        title: "Payment failed",
        subtitle: "Outgoing payment of " +
            FormatCurrency().format(
                transaction.get("currencyCode"), transaction.get("amount")) +
            " failed to " +
            transaction.get("address"),
        color: Theme.of(context).errorColor);
  }
}
