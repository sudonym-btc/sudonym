import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class ReceiverPage extends StatelessWidget {
  final Receiver receiver;
  const ReceiverPage(this.receiver, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<ReceiverCubit, ReceiverCubitState, Receiver>(
        entity: receiver,
        fetch: true,
        builder: (context, state) {
          if (state.entity == null) {
            return StatusPage(
                title: '',
                subtitle: '',
                content: const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                color: Colors.indigo.shade800);
          } else if (state.entity!.received > 0) {
            return const StatusPage(
                title: 'Received',
                subtitle: 'Received payment.',
                icon: FontAwesomeIcons.check,
                color: Colors.green);
          }

          return StatusPage(
              title: 'Receiving',
              subtitle: 'Waiting for payment...',
              content: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
              color: Colors.indigo.shade800);
        });
  }
}
