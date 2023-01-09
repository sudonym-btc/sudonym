import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class ReceiverPage extends StatefulWidget {
  final Receiver entity;
  final CreatedOrUpdated<Transaction>? Function(CreatedOrUpdated<Transaction> t)
      handle;
  const ReceiverPage({required this.entity, required this.handle, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReceiverPageState();
}

class ReceiverPageState extends State<ReceiverPage> {
  @override
  void initState() {
    getIt<TransactionHandlerService>().callbacks.add(widget.handle);
    super.initState();
  }

  @override
  void dispose() {
    getIt<TransactionHandlerService>().callbacks.remove(widget.handle);
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
