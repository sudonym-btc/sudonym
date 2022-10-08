import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

import '../buttons.dart';
import '../inputs.dart';
import '../notifications.dart';
import '../typography.dart';
import '../widgets/widgets.dart';

void main() {
  runApp(const HotreloadWidgetbook());
}

class HotreloadWidgetbook extends StatelessWidget {
  const HotreloadWidgetbook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      categories: [buttons, inputs, typography, widgets, notifications],
      themes: [
        WidgetbookTheme(
          name: 'Light',
          data: getTheme(),
        ),
        WidgetbookTheme(
          name: 'Dark',
          data: getTheme(light: false),
        ),
      ],
      appInfo: AppInfo(name: 'Example'),
    );
  }
}
