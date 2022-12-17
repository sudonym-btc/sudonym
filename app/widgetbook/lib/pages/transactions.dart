import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/mock/parsed_data.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent transactions = WidgetbookComponent(
  name: 'Transaction',
  useCases: [
    WidgetbookUseCase(
        name: 'IncomingSuccess',
        builder: (context) {
          return TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction')
                .where((element) => !element.outgoing && element.status == true)
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'IncomingPending',
        builder: (context) {
          return TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction')
                .where((element) => !element.outgoing && element.status == null)
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'IncomingFailed',
        builder: (context) {
          return TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction')
                .where(
                    (element) => !element.outgoing && element.status == false)
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'OutgoingSuccess',
        builder: (context) {
          return TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction')
                .where((element) => element.outgoing && element.status == true)
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'OutgoingPending',
        builder: (context) {
          return TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction')
                .where((element) => element.outgoing && element.status == null)
                .first,
          );
        }),
    WidgetbookUseCase(
        name: 'OutgoingFailed',
        builder: (context) {
          return TransactionPage(
            entity: Mockdata.getData<Transaction>('transaction')
                .where((element) => element.outgoing && element.status == false)
                .first,
          );
        }),
  ],
);
