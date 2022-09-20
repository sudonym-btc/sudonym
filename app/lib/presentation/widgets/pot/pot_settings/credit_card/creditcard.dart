import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreditCard extends StatefulWidget {
  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  double horizontalDrag = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
      onHorizontalDragUpdate: (horizontal) {
        setState(() {
          horizontalDrag += horizontal.delta.dx;
          horizontalDrag %= 360;
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(pi / 180 * horizontalDrag),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
          child: Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColorDark
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: horizontalDrag <= 90 || horizontalDrag >= 270
                  ? cardFront()
                  : cardBack(),
            ),
          ),
        ),
      ),
    ));
  }

  Widget cardFront() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'sudonym',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              '4729  8363  9583  8348',
              style: TextStyle(
                color: Color.fromARGB(255, 19, 19, 19),
                fontSize: 18,
                wordSpacing: 15,
                shadows: [
                  BoxShadow(
                    blurRadius: 1,
                    spreadRadius: 1,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              150,
              0,
              0,
              0,
            ),
            child: Text(
              'EXP 09 / 26',
              style: TextStyle(
                color: Color.fromARGB(255, 19, 19, 19),
              ),
            ),
          ),
          // const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              'MIKE HUNT',
              style: TextStyle(
                  color: Color.fromARGB(255, 19, 19, 19), fontSize: 15),
            ),
          ),
          // const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              '26-48-28',
              style: TextStyle(
                  color: Color.fromARGB(255, 19, 19, 19), fontSize: 20),
            ),
          ),
          // const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              '58906447',
              style: TextStyle(
                color: Color.fromARGB(255, 19, 19, 19),
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget cardBack() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            height: 35,
            color: const Color.fromARGB(255, 19, 19, 19),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(120, 5, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 25,
                  width: 150,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 154, 154, 154)),
                  child: const Text('123'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
