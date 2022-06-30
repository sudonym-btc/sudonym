class Transaction {
  num id;
  bool outgoing;
  String addressType;
  String address;
  dynamic /* String | null */ transactionId;
  String potId;
  num amount;
  bool confirmed;
  bool spendable;
  dynamic /* String | null */ OnchainTransactionId;
  dynamic /* String | null */ LightningInvoiceId;
  DateTime createdAt;
  Transaction(
      this.id,
      this.outgoing,
      this.addressType,
      this.address,
      this.transactionId,
      this.potId,
      this.amount,
      this.confirmed,
      this.spendable,
      this.OnchainTransactionId,
      this.LightningInvoiceId,
      this.createdAt) {}
  static Transaction fromJson(Map<String, dynamic> json) {
    return new Transaction(
        json["id"],
        json["outgoing"],
        json["addressType"],
        json["address"],
        json["transactionId"],
        json["potId"],
        json["amount"],
        json["confirmed"],
        json["spendable"],
        json["OnchainTransactionId"],
        json["LightningInvoiceId"],
        DateTime.parse(json["createdAt"]));
  }
}
