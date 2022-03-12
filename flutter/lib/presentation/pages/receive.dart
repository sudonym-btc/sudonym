import 'package:flutter/material.dart';

import '../widgets/receive/bolt12.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        Tab(text: 'Bolt 11'),
                        Tab(text: 'Bolt 12'),
                        Tab(
                          text: 'LnUrl',
                        ),
                        Tab(
                          text: 'Onchain',
                        ),
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      ReceiveBolt12(),
                      ReceiveBolt12(),
                      ReceiveBolt12(),
                      ReceiveBolt12(),
                    ],
                  ),
                ))));
  }
}
