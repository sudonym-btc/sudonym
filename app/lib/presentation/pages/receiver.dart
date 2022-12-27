import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class ReceiverPage extends StatefulWidget {
  final Receiver entity;
  const ReceiverPage({required this.entity, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReceiverPageState();
}

class ReceiverPageState extends State<ReceiverPage> {
  CreatedOrUpdated<Transaction>? handle(CreatedOrUpdated<Transaction> t) {
    // Don't bubble this event to global transaction handler if already on this page
    if (t.entity.receiverId == widget.entity.id) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => TransactionPage(entity: t.entity),
              fullscreenDialog: true),
          (route) => route.isFirst);
      return null;
    }
    return t;
  }

  @override
  void initState() {
    getIt<TransactionHandlerService>().callbacks.add(handle);
    super.initState();
  }

  @override
  void dispose() {
    getIt<TransactionHandlerService>().callbacks.remove(handle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<ReceiverCubit, ReceiverCubitState, Receiver>(
        entity: widget.entity,
        fetch: true,
        builder: (context, state) {
          if (state.entity == null) {
            return StatusPage(
                title: null,
                subtitle: null,
                content: const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                color: loadingColor);
          }
          // else if (state.entity!.received > 0) {
          //   return StatusPage(
          //       title: AppLocalizations.of(context)!.received,
          //       subtitleText: AppLocalizations.of(context)!.receivedPayment,
          //       icon: FontAwesomeIcons.check,
          //       color: Colors.green);
          // }

          // don't show success page as will route to transaction page anyway

          return StatusPage(
              title: AppLocalizations.of(context)!.receiving,
              subtitleText: AppLocalizations.of(context)!.waitingForPayment,
              content: loader,
              color: loadingColor);
        });
  }
}
