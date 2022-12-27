import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/bloc/transaction_handler.service.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class TransactionHandler extends StatefulWidget {
  final Widget child;
  const TransactionHandler({required this.child, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TransactionHandlerState();
  }
}

class TransactionHandlerState extends State<TransactionHandler>
    with IncomingTransactionLogger {
  final TransactionHandlerService _transactionHandlerService =
      getIt<TransactionHandlerService>();

  @override
  void initState() {
    _transactionHandlerService.callbacks.add(ringtone);
    _transactionHandlerService.callbacks.after.add(callback);
    super.initState();
  }

  CreatedOrUpdated<Transaction> ringtone(CreatedOrUpdated<Transaction> event) {
    if ((event.entity.status == true &&
        (event.changed.contains('status') || event.created))) {
      FlutterRingtonePlayer.play(fromAsset: 'assets/audio/ping.mp3');
    }
    return event;
  }

  CreatedOrUpdated<Transaction> callback(CreatedOrUpdated<Transaction> event) {
    loggy.i('Transaction callback ${event.entity.id}');

    // When receiving a transaction popup the transaction details page
    if (event.entity.outgoing == false) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TransactionPage(entity: event.entity),
            fullscreenDialog: true),
      );
    }
    return event;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  dispose() {
    super.dispose();
    _transactionHandlerService.callbacks.remove(ringtone);
    _transactionHandlerService.callbacks.after.remove(callback);
  }
}
