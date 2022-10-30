import 'package:sudonym/presentation/widgets/pot/credit_card/creditcard.dart';

import 'package:flutter/material.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: CreditCard(),
      ),
    );
  }
}
