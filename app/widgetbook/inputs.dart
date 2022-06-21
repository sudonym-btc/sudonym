import 'package:sudonym/presentation/components/input/text_input.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory inputs = WidgetbookCategory(
  name: 'inputs',
  widgets: [
    WidgetbookComponent(
      name: 'Text with button',
      useCases: [
        WidgetbookUseCase(
          name: 'elevated',
          builder: (context) => TextInput(),
        ),
      ],
    ),
  ],
);
