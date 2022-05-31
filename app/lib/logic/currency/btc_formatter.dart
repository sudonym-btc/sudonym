import 'package:number_display/number_display.dart';

final display = createDisplay(
  separator: ',',
  length: 12,
  decimal: 0,
  roundingType: RoundingType.round,
);

String formatBTC(num amount) {
  if(amount > 0.1) {
    return amount.toStringAsPrecision(4).toString() + " BTC";
  } else {
    return display(amount * 100000000) + " sats";
  }
}
