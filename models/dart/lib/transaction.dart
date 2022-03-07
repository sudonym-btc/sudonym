class Transaction {
  String id;
  String transactionId;
  String potId;
  num amount;
  String OnchainTransactionId;
  String LightningTransactionId;
  DateTime createdAt;
  Transaction(this.id, this.transactionId, this.potId, this.amount,
      this.OnchainTransactionId, this.LightningTransactionId, this.createdAt) {}
  static fromJson(Map<String, dynamic> json) {
    return new Transaction(
        json["id"],
        json["transactionId"],
        json["potId"],
        json["amount"],
        json["OnchainTransactionId"],
        json["LightningTransactionId"],
        DateTime.parse(json["createdAt"]));
  }
}
