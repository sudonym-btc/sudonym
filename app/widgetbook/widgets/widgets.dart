import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory widgets = WidgetbookCategory(
  name: 'widgets',
  widgets: [
    WidgetbookComponent(
      name: 'Slideable',
      useCases: [
        WidgetbookUseCase(
          name: 'elevated',
          builder: (context) => Scaffold(
            body: ScreenSlideable(
                top: Container(
                  color: Colors.green,
                  child: const Header(
                    'Yodel',
                  ),
                ),
                bottom: Container(
                  color: Colors.red,
                  child: const Text('LeyHiHooo'),
                )),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'Pot',
      useCases: [
        // WidgetbookUseCase(
        //   name: 'elevated',
        //   builder: (context) => const PotHeader(),
        // ),
      ],
    ),
  ],
);
