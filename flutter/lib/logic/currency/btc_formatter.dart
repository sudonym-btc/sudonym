String formatBTC(num amount) {
  if(amount > 0.1) {
    return amount.toStringAsPrecision(4).toString() + " BTC";
  } else {
    return (amount * 10000000).toStringAsPrecision(4).toString() + " sats";
  }
}
