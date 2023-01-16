class PaymentRequestCallback {
  String pr;
  dynamic /* bool | null */ disposable;
  dynamic /* | null */ routes;
  dynamic /* dynamic | null */ successAction;
  PaymentRequestCallback(this.pr,
      [this.disposable, this.routes, this.successAction]) {}
}
