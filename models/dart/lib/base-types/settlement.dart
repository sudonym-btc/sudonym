class Settlement {
  num id;
  String fromCurrency;
  String toCurrency;
  String exchangeId;
  String orderId;
  Settlement(this.id, this.fromCurrency, this.toCurrency, this.exchangeId,
      this.orderId) {}
  static Settlement fromJson(dynamic json) {
    return new Settlement(json["id"], json["fromCurrency"], json["toCurrency"],
        json["exchangeId"], json["orderId"]);
  }
}
