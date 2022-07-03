import 'package:money_formatter/money_formatter.dart';
import 'package:sudonym/logic/currency/btc_formatter.dart';

class FormatCurrency {
  String format(String currency, num amount) {
    if (currency == "BTC") return formatBTC(amount);

    MoneyFormatter fmf = MoneyFormatter(
        amount: amount.toDouble(),
        settings: MoneyFormatterSettings(
          symbol: currency,
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: '',
          fractionDigits: 3,
        ));
    return fmf.output.symbolOnLeft;
  }
}
