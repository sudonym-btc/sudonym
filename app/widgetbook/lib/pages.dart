import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/mock/parsed_data.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookCategory pages = WidgetbookCategory(
  name: 'Pages',
  widgets: [
    WidgetbookComponent(
      name: 'Transaction',
      useCases: [
        WidgetbookUseCase(
          name: 'elevated',
          builder: (context) => TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction').first,
          ),
        ),
      ],
    ),
  ],
);
