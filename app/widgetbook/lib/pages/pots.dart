import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/mock/parsed_data.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent pots = WidgetbookComponent(
  name: 'Pots',
  useCases: [
    WidgetbookUseCase(
        name: 'USD',
        builder: (context) {
          return PotPage(
            entity: Mockdata.getData<Pot>('pot')
                .where((element) => element.currency == 'USD')
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'BTC',
        builder: (context) {
          return PotPage(
            entity: Mockdata.getData<Pot>('pot')
                .where((element) => element.currency == 'BTC')
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'Create Pot',
        builder: (context) {
          return EditPot(
            entity: Mockdata.getData<Pot>('pot')
                .where((element) => element.currency == 'BTC')
                .first,
          );
        }),
  ],
);
