import 'package:sudonym.models/base-types/types/currency.dart';
import 'package:intl/intl.dart';

String formatBTC(num amount) {
  if (amount > 0.1) {
    return "${amount.toStringAsPrecision(4)} BTC";
  } else {
    return "${NumberFormat.compact().format(amount * SATOSHIS)} sats";
  }
}
