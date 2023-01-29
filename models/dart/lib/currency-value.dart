class CurrencyValue {
  num amount;
  String currency;
  CurrencyValue(this.amount, this.currency) {}
  static CurrencyValue fromJson(Map<String, dynamic> json) {
    return new CurrencyValue(json["amount"], json["currency"]);
  }

  dynamic toJson() {
    return {"amount": this.amount, "currency": this.currency};
  }
}
