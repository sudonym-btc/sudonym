import 'package:number_display/number_display.dart';

final display = createDisplay(
  separator: ',',
  length: 12,
  decimal: 0,
  roundingType: RoundingType.round,
);

String formatBTC(num amount) {
  if (amount > 10000000) {
    return (amount / 100000000).toStringAsPrecision(4).toString() + " BTC";
  } else {
    return display(amount) + " sats";
  }
}
