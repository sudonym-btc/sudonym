import 'dart:io';

import 'package:money_formatter/money_formatter.dart';
import 'package:sudonym/logic/currency/btc_formatter.dart';
import 'package:intl/intl.dart';

class FormatCurrency {
  String format(String currency, num amount) {
    if (currency == 'BTC') return formatBTC(amount);
    var format = NumberFormat.simpleCurrency(
        locale: Platform.localeName, name: currency);

    MoneyFormatter fmf = MoneyFormatter(
        amount: amount.toDouble(),
        settings: MoneyFormatterSettings(
          symbol: format.currencySymbol,
          thousandSeparator: ',',
          decimalSeparator: '.',
          symbolAndNumberSeparator: '',
          fractionDigits: 2,
        ));
    return fmf.output.symbolOnLeft;
  }
}
