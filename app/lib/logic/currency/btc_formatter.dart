import 'package:intl/intl.dart';
import 'package:sudonym.models/types/currency.dart';

String formatBTC(num amount) {
  if (amount > 0.1) {
    return '${amount.toStringAsPrecision(4)} BTC';
  } else {
    return '${NumberFormat.compact().format(amount * SATOSHIS)} sats';
  }
}
