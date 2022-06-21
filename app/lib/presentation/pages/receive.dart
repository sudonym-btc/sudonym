import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/widgets/receive/lnurl.dart';
import 'package:sudonym/presentation/widgets/receive/onchain.dart';

import '../widgets/receive/bolt11.dart';
import '../widgets/receive/bolt12.dart';

class ReceivePageArgs {
  String potId;

  ReceivePageArgs(@required this.potId);
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
                length: 4,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Receive'),
                    bottom: const TabBar(
                      tabs: [
                        Tab(
                            text: 'Bolt 11',
                            icon: FaIcon(
                              FontAwesomeIcons.bolt,
                              size: 12,
                            )),
                        Tab(
                            text: 'Bolt 12',
                            icon: FaIcon(FontAwesomeIcons.bolt, size: 12)),
                        Tab(
                            text: 'LnUrl',
                            icon: FaIcon(FontAwesomeIcons.wifi, size: 12)),
                        Tab(
                            text: 'Onchain',
                            icon: FaIcon(FontAwesomeIcons.link, size: 12)),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      ReceiveBolt11(potId: data.potId),
                      ReceiveBolt12(potId: data.potId),
                      ReceiveLnUrl(potId: data.potId),
                      ReceiveOnchain(potId: data.potId),
                    ],
                  ),
                ))));
  }
}
