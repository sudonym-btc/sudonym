import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
          child: Text('sudo|nym', style: TextStyle(fontFamily: 'Satoshi', fontSize: 24),),
        ),
      );
  }
}