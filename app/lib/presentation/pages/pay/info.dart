import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/index.dart';

import 'package:sudonym/presentation/pages/action/action_flow.dart';

class PayInfoPage extends ActionFlow<Payment, Payment> {
  final Payment action;

  const PayInfoPage(
      {super.key,
      required super.onDone,
      required super.onError,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
      future: () {
        return PayManager().info(action);
      },
      onSuccess: donePage,
      onError: errorPage,
    );
  }

  StatusPage donePage(BuildContext context, r) {
    return StatusPage(
        color: Colors.indigo.shade800,
        title: AppLocalizations.of(context)!.paymentInfo,
        subtitle: AppLocalizations.of(context)!.gatheredPaymentInformation,
        content: PaymentInfoPreview(entity: r),
        actions: ButtonBar(children: [
          ElevatedButton.icon(
            label: Text(AppLocalizations.of(context)!.send),
            icon: const FaIcon(FontAwesomeIcons.paperPlane, size: iconSize),
            onPressed: () {
              onDone(r);
            },
            style: raisedButtonStyle,
          )
        ]));
  }

  StatusPage errorPage(BuildContext context, Object err) {
    return StatusPage(
        color: Colors.red,
        title: AppLocalizations.of(context)!.failed,
        content: err is DioError
            ? Text(err.response.toString())
            : Text(err.toString()));
  }

  StatusPage loadingPage(BuildContext context) {
    return StatusPage(
        color: Colors.indigo.shade800,
        title: AppLocalizations.of(context)!.paymentInfo,
        subtitle: AppLocalizations.of(context)!.gatheringPaymentInfomation,
        content: loader);
  }
}

class PaymentInfoPreview extends StatelessWidget {
  final Payment entity;

  const PaymentInfoPreview({required this.entity, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Table(
        children: [
          TableRow(children: [
            Text(AppLocalizations.of(context)!.amount),
            Text(FormatCurrency()
                .format(entity.currency ?? 'BTC', entity.amount ?? 0))
          ]),
          TableRow(children: [
            Text(AppLocalizations.of(context)!.fee),
            Text(FormatCurrency()
                .format(entity.feeCurrency ?? 'BTC', entity.fee ?? 0))
          ]),
          TableRow(children: [
            Text(AppLocalizations.of(context)!.address),
            Text(
              entity.address ?? '',
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
          TableRow(children: [
            Text(AppLocalizations.of(context)!.name),
            Text(
              entity.originalAddress,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
        ],
      )
    ]);
  }
}
