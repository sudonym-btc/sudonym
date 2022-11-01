import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceivePageArgs {
  Pot pot;

  ReceivePageArgs(this.pot);
}

class ReceivePage extends StatelessWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReceivePageArgs data =
        ModalRoute.of(context)!.settings.arguments as ReceivePageArgs;

    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
            child: Container(
                color: Colors.blue,
                constraints: const BoxConstraints(maxWidth: 100),
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
                          ReceiveLnUrl(pot: data.pot),
                          ReceiveOnchain(pot: data.pot),
                          ReceiveBolt11(pot: data.pot),
                          // ReceiveBolt12(potId: data.potId),
                        ],
                      ),
                    )))));
  }
}
