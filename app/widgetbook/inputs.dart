import 'package:sudonym/presentation/components/input/username.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory inputs = WidgetbookCategory(
  name: 'inputs',
  widgets: [
    WidgetbookComponent(name: 'Drop Down Menu', useCases: []),
    WidgetbookComponent(
      name: 'Text with button',
      useCases: [
        WidgetbookUseCase(
          name: 'Username Input',
          builder: (context) => const UsernameInput(),
        ),
      ],
    ),
  ],
);
