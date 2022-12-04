import 'package:intl/intl.dart';
import 'package:sudonym.models/index.dart';

String formatBTC(num amount) {
  if (amount > 0.1) {
    return '${NumberFormat.compact().format(amount)} BTC';
  } else {
    return '${NumberFormat.compact().format(amount * SATOSHIS)} sats';
  }
}
