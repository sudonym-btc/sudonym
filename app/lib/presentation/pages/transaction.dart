import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/transaction.cubit.dart';
import 'package:sudonym/presentation/widgets/status_page/status_page.dart';

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
                        .id))
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
          } else if (state.entity!.outgoing) {
            if (state.entity!.confirmed) {
              return _OutgoingComplete(transaction: state.entity!);
            }
            return _OutgoingPending(transaction: state.entity!);
          } else {
            if (state.entity!.confirmed) {
              return _IncomingComplete(transaction: state.entity!);
            }
            return _IncomingPending(transaction: state.entity!);
          }
        })));
  }
}

class _OutgoingPending extends StatelessWidget {
  final Transaction transaction;
  const _OutgoingPending({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: "Payment pending",
        subtitle: "Payment is currently in transit",
        content: Center(child: CircularProgressIndicator(color: Colors.white)),
        color: Colors.indigo.shade800);
  }
}

class _OutgoingComplete extends StatelessWidget {
  final Transaction transaction;
  const _OutgoingComplete({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: "Payment sent",
        subtitle: "Payment has successfully been sent",
        icon: FontAwesomeIcons.check,
        color: Colors.green);
  }
}

class _IncomingPending extends StatelessWidget {
  final Transaction transaction;
  const _IncomingPending({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: "Payment incoming",
        subtitle: "Payment is currently in transit",
        content: Center(child: CircularProgressIndicator(color: Colors.white)),
        color: Colors.indigo.shade800);
  }
}

class _IncomingComplete extends StatelessWidget {
  final Transaction transaction;
  const _IncomingComplete({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusPage(
        title: "Payment received",
        subtitle: "Payment of 234,234,234 sats received",
        icon: FontAwesomeIcons.check,
        color: Colors.green);
  }
}
