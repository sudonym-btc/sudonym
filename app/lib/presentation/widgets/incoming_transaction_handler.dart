import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/index.dart';

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
  late TransactionRepository _transactionRepository;

  @override
  void initState() {
    _transactionRepository = getIt<TransactionRepository>();
    _transactionRepository.created.stream.listen((event) {
      if (event.outgoing == false) {
        FlutterRingtonePlayer.playNotification();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => TransactionPage(entity: event),
              fullscreenDialog: true),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
