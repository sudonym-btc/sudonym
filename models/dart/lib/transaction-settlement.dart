class TransactionSettlement {
  num id;
  dynamic /* String | null */ transactionId;
  dynamic /* bool | null */ status;
  DateTime createdAt;
  TransactionSettlement(
      this.id, this.transactionId, this.status, this.createdAt) {}
  static TransactionSettlement fromJson(Map<String, dynamic> json) {
    return new TransactionSettlement(
        json["id"], json["transactionId"], json["status"], DateTime.parse(json["createdAt"]));
  }
}
