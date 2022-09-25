import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

class AddMoney extends StatelessWidget {
  final String str1;
  final String str2;

  const AddMoney({
    Key? key,
    required this.str1,
    required this.str2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Text text = Text(
      str1,
      style:
          const TextStyle(color: Color.fromARGB(255, 82, 81, 81), fontSize: 17),
    );
    Text text2 = Text(
      str2,
      style: const TextStyle(fontSize: 17, color: textColor),
    );
    return Center(
      child: Container(
        width: 350,
        height: 75,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1)),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0), child: text),
            const SizedBox(height: 1),
            text2,
          ],
        ),
      ),
    );
  }
}
