import 'dart:async';
import 'package:flutter/material.dart';

showCustomSnackbar({
  required BuildContext context,
  required String contentText,
  required String actionText,
  Function()? onPressed,
  void Function()? afterExecuteMethod,
  int second = 4,
}) {
  bool isExecute = true;
  final snackbar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 22.0),
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: second * 1000.toDouble()),
            duration: Duration(seconds: second),
            builder: (context, double value, child) {
              return Stack(
                fit: StackFit.loose,
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      value: value / (second * 1000),
                      color: Colors.grey[850],
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Center(
                    child: Text(
                      (second - (value / 1000)).toInt().toString(),
                      textScaleFactor: 0.85,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(child: Text(contentText)),
        InkWell(
          splashColor: Colors.white,
          onTap: () {
            onPressed!();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            isExecute = !isExecute;
            return;
          },
          child: Container(
            color: Colors.grey[850],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 8.0),
                Text(
                  actionText,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                  textScaleFactor: 1.1,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.grey[850],
    duration: Duration(seconds: second),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(6.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackbar);

  Timer(Duration(seconds: second), () {
    if (isExecute && afterExecuteMethod != null) afterExecuteMethod();
  });
}
