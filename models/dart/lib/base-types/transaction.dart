class Transaction {
  num id;
  dynamic /* String | null */ txid;
  num potId;
  bool outgoing;
  dynamic /* String | null */ type;
  dynamic /* String | null */ originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ description;
  dynamic /* num | null */ transactionId;
  num amount;
  dynamic /* bool | null */ status;
  String currencyCode;
  DateTime createdAt;
  Transaction(
      this.id,
      this.txid,
      this.potId,
      this.outgoing,
      this.type,
      this.originalAddress,
      this.address,
      this.description,
      this.transactionId,
      this.amount,
      this.status,
      this.currencyCode,
      this.createdAt) {}
  static Transaction fromJson(Map<String, dynamic> json) {
    return new Transaction(
        json["id"],
        json["txid"],
        json["potId"],
        json["outgoing"],
        json["type"],
        json["originalAddress"],
        json["address"],
        json["description"],
        json["transactionId"],
        json["amount"],
        json["status"],
        json["currencyCode"],
        DateTime.parse(json["createdAt"]));
  }
}
