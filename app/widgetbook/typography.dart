import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory typography = WidgetbookCategory(
  name: 'typography',
  widgets: [
    WidgetbookComponent(
      name: 'Header',
      useCases: [
        WidgetbookUseCase(
          name: 'Header',
          builder: (context) => Column(children: const [
            Header('Test Header'),
            Subtitle('Subtitle'),
            Emphasized('Emphasized')
          ]),
        ),
      ],
    ),
  ],
);
