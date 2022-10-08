import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceivePageArgs {
  num potId;

  ReceivePageArgs(this.potId);
}

class ReceivePage extends StatelessWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReceivePageArgs data =
        ModalRoute.of(context)!.settings.arguments as ReceivePageArgs;

    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context)!.receive),
                    bottom: const TabBar(
                      tabs: [
                        Tab(icon: FaIcon(FontAwesomeIcons.wifi, size: 12)),
                        Tab(icon: FaIcon(FontAwesomeIcons.link, size: 12)),
                        Tab(
                            icon: FaIcon(
                          FontAwesomeIcons.bolt,
                          size: 12,
                        )),
                        // Tab(icon: FaIcon(FontAwesomeIcons.bolt, size: 12)),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      ReceiveLnUrl(potId: data.potId),
                      ReceiveOnchain(potId: data.potId),
                      ReceiveBolt11(potId: data.potId),
                      // ReceiveBolt12(potId: data.potId),
                    ],
                  ),
                ))));
  }
}
