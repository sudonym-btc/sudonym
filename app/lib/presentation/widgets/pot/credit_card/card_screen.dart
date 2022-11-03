import 'package:flutter/material.dart';
import 'package:sudonym/presentation/widgets/pot/credit_card/creditcard.dart';

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
