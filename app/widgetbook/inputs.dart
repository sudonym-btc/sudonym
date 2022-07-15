import 'package:sudonym/presentation/components/input/language/language_menu.dart';
import 'package:sudonym/presentation/components/input/text_input.dart';
import 'package:sudonym/presentation/components/input/username.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory inputs = WidgetbookCategory(
  name: 'inputs',
  widgets: [
    WidgetbookComponent(name: 'Drop Down Menu', useCases: [
      WidgetbookUseCase(
        name: 'Language Menu',
        builder: (context) => const LanguageMenu(
          title: '',
        ),
      )
    ]),
    WidgetbookComponent(
      name: 'Text with button',
      useCases: [
        WidgetbookUseCase(
          name: 'elevated',
          builder: (context) => TextInput(),
        ),
        WidgetbookUseCase(
          name: 'Username Input',
          builder: (context) => const UsernameInput(),
        ),
      ],
    ),
  ],
);
