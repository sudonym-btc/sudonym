class Receiver {
  num id;
  num potId;
  String type;
  num amount;
  String amountCurrency;
  String data;
  DateTime createdAt;
  Receiver(this.id, this.potId, this.type, this.amount, this.amountCurrency,
      this.data, this.createdAt) {}
  static Receiver fromJson(Map<String, dynamic> json) {
    return new Receiver(json["id"], json["potId"], json["type"], json["amount"],
        json["amountCurrency"], json["data"], DateTime.parse(json["createdAt"]));
  }
}
