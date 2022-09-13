class Settlement {
  num id;
  String fromCurrency;
  String toCurrency;
  String exchangeId;
  String orderId;
  bool status;
  Settlement(this.id, this.fromCurrency, this.toCurrency, this.exchangeId,
      this.orderId, this.status) {}
  static Settlement fromJson(dynamic json) {
    return new Settlement(json["id"], json["fromCurrency"], json["toCurrency"],
        json["exchangeId"], json["orderId"], json["status"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "fromCurrency": this.fromCurrency,
      "toCurrency": this.toCurrency,
      "exchangeId": this.exchangeId,
      "orderId": this.orderId,
      "status": this.status
    };
  }
}
