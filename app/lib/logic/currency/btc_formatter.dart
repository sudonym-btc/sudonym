import 'package:intl/intl.dart';
import 'package:sudonym.models/index.dart';
import 'package:universal_io/io.dart';

String formatBTC(num amount) {
  if (amount > 0.1) {
    return '${NumberFormat.compact(locale: Platform.localeName).format(amount)} BTC';
  } else {
    return '${NumberFormat.compact(locale: Platform.localeName).format(amount * SATOSHIS)} sats';
  }
}
