import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/bloc/incoming_transaction_handler.service.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class IncomingTransactionHandler extends StatefulWidget {
  final Widget child;
  const IncomingTransactionHandler({required this.child, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IncomingTransactionHandlerState();
  }
}

class IncomingTransactionHandlerState
    extends State<IncomingTransactionHandler> {
  final IncomingTransactionHandlerService _incomingTransactionHandlerService =
      getIt<IncomingTransactionHandlerService>();

  @override
  void initState() {
    _incomingTransactionHandlerService.callbacks.after.add(callback);
    super.initState();
  }

  Transaction callback(Transaction event) {
    if (event.outgoing == false) {
      FlutterRingtonePlayer.playNotification();
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => TransactionPage(entity: event),
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
    _incomingTransactionHandlerService.callbacks.remove(callback);
  }
}
