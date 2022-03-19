class TransactionConfirm {
  String name;
  String address;
  num feeMSat;
  dynamic /* num | null */ ContactId;
  TransactionConfirm(this.name, this.address, this.feeMSat, this.ContactId) {}
  static fromJson(Map<String, dynamic> json) {
    return new TransactionConfirm(
        json["name"], json["address"], json["feeMSat"], json["ContactId"]);
  }
}
