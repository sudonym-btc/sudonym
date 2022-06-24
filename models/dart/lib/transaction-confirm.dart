class TransactionConfirm {
  String name;
  String address;
  num feeMSat;
  num amount;
  dynamic /* num | null */ ContactId;
  TransactionConfirm(
      this.name, this.address, this.feeMSat, this.amount, this.ContactId) {}
  static TransactionConfirm fromJson(Map<String, dynamic> json) {
    return new TransactionConfirm(json["name"], json["address"],
        json["feeMSat"], json["amount"], json["ContactId"]);
  }
}
