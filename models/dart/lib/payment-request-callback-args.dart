class PaymentRequestCallbackArgs {
  num amount;
  dynamic /* String | null */ comment;
  dynamic /* dynamic | null */ payerData;
  PaymentRequestCallbackArgs(this.amount, [this.comment, this.payerData]) {}
}
