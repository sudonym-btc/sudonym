import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class SenderPage extends StatelessWidget {
  final Sender entity;
  const SenderPage({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<SenderCubit, SenderCubitState, Sender>(
        entity: entity,
        builder: ((context, state) {
          if (state.loading && state.entity == null) {
            return StatusPage(
                title: null,
                subtitle: null,
                content: loader,
                color: Colors.indigo.shade800);
          }
          copy() {
            FocusScope.of(context).unfocus();

            FlutterClipboard.copy(state.entity!.data).then((value) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.copiedToClipboard),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          }

          Widget image = const Center(child: CircularProgressIndicator());
          image = GestureDetector(
            onTap: copy,
            child: QrImage(
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle),
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle),
                data: state.entity!.data,
                foregroundColor:
                    Theme.of(context).appBarTheme.titleTextStyle!.color,
                version: QrVersions.auto),
          );
          var buttons = [
            Button(
              // icon: const FaIcon(FontAwesomeIcons.copy, size: iconSize),
              onPressed: state.loading ? null : copy,
              text: (AppLocalizations.of(context)!.copy),
            ),
            Button(
              // icon: const FaIcon(FontAwesomeIcons.share, size: iconSize),
              onPressed: state.loading
                  ? null
                  : () {
                      Share.share(state.entity!.data);
                    },
              text: (AppLocalizations.of(context)!.share),
            ),
          ];
          return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.voucher),
              ),
              body: SafeArea(
                  child: CustomPadding(
                      multiplier: 2,
                      child: Column(
                        children: [
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const VertDivider(2),
                              image,
                              const VertDivider(),
                              CustomPadding(
                                  child: AmountText(
                                amount: entity.limitMax,
                                fromCurrency: entity.amountCurrency,
                                toCurrency: entity.amountCurrency,
                                builder: ((val) => Info(
                                    AppLocalizations.of(context)!
                                        .voucherDescription(val))),
                              ))
                            ],
                          )),
                          ButtonBar(children: buttons)
                        ],
                      ))));
        }));
  }
}
