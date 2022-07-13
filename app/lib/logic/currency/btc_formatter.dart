import 'package:number_display/number_display.dart';

final display = createDisplay(
  separator: ',',
  length: 12,
  decimal: 0,
  roundingType: RoundingType.round,
);

String formatBTC(num amount) {
  const mSats = 100000000000;
  if (amount > mSats) {
    return (amount / mSats).toStringAsPrecision(4).toString() + " BTC";
  } else {
    return display(amount / 1000) + " sats";
  }
}
