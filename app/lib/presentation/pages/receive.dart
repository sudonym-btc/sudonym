import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/presentation/index.dart';

class ReceivePage extends StatelessWidget {
  final ReceiveOptions? args;
  const ReceivePage({Key? key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReceiveOptions data =
        args ?? ModalRoute.of(context)!.settings.arguments as ReceiveOptions;

    List<Widget> children = [
      if (data.types.contains('lnurl')) ReceiveLnUrl(opts: data),
      if (data.types.contains('bolt11')) ReceiveBolt11(opts: data),
      if (data.types.contains('onchain')) ReceiveOnchain(opts: data),
      // ReceiveBolt12(potId: data.potId),
    ];

    return Container(
        color: Theme.of(context).backgroundColor,
        child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.receive),
              // bottom: const TabBar(
              //   tabs: [
              //     Tab(
              //         text: 'LNURL',
              //         icon: FaIcon(FontAwesomeIcons.wifi, size: 12)),
              //     Tab(
              //         text: 'ONCHAIN',
              //         icon: FaIcon(FontAwesomeIcons.link, size: 12)),
              //     Tab(
              //         text: 'BOLT11',
              //         icon: FaIcon(
              //           FontAwesomeIcons.bolt,
              //           size: 12,
              //         )),
              //     // Tab(icon: FaIcon(FontAwesomeIcons.bolt, size: 12)),
              //   ],
              // ),
            ),
            body: SafeArea(
                child: DefaultTabController(
              length: children.length,
              child: TabBarView(
                children: children,
              ),
            ))));
  }
}
