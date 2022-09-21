import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory buttons = WidgetbookCategory(
  name: 'buttons',
  widgets: [
    WidgetbookComponent(
      name: 'Button',
      useCases: [
        WidgetbookUseCase(
          name: 'elevated',
          builder: (context) => const Button(text: 'Ok'),
        ),
        WidgetbookUseCase(
          name: 'icon',
          builder: (context) =>
              const Button(icon: FaIcon(FontAwesomeIcons.addressBook)),
        ),
        WidgetbookUseCase(
          name: 'icon and text',
          builder: (context) => const Button(
              text: 'OK', icon: FaIcon(FontAwesomeIcons.addressBook)),
        ),
        WidgetbookUseCase(name: 'NFC', builder: (context) => const NFC())
      ],
    ),
  ],
);
