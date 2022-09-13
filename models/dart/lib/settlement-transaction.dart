class SettlementTransaction {
  num transactionId;
  num settlementId;
  SettlementTransaction(this.transactionId, this.settlementId) {}
  static SettlementTransaction fromJson(dynamic json) {
    return new SettlementTransaction(
        json["transactionId"], json["settlementId"]);
  }

  dynamic toJson() {
    return {
      "transactionId": this.transactionId,
      "settlementId": this.settlementId
    };
  }
}
