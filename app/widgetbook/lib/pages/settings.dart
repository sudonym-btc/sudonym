import 'package:sudonym/presentation/index.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent settings = WidgetbookComponent(
  name: 'Settings',
  useCases: [
    WidgetbookUseCase(
        name: 'Settings',
        builder: (context) {
          return SettingsPage();
        }),
  ],
);
