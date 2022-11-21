import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class ReceiverPage extends StatelessWidget {
  final Receiver entity;
  const ReceiverPage({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<ReceiverCubit, ReceiverCubitState, Receiver>(
        entity: entity,
        fetch: true,
        builder: (context, state) {
          if (state.entity == null) {
            return StatusPage(
                title: null,
                subtitle: null,
                content: const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                color: Colors.indigo.shade800);
          } else if (state.entity!.received > 0) {
            return StatusPage(
                title: AppLocalizations.of(context)!.received,
                subtitleText: AppLocalizations.of(context)!.receivedPayment,
                icon: FontAwesomeIcons.check,
                color: Colors.green);
          }

          return StatusPage(
              title: AppLocalizations.of(context)!.receiving,
              subtitleText: AppLocalizations.of(context)!.waitingForPayment,
              content: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
              color: Colors.indigo.shade800);
        });
  }
}
