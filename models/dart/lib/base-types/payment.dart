class Payment {
  String originalAddress;
  dynamic /* String | null */ address;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  dynamic /* num | null */ feeMSat;
  Payment(this.originalAddress, this.address, this.amount, this.minAmount,
      this.maxAmount, this.feeMSat) {}
  static Payment fromJson(Map<String, dynamic> json) {
    return new Payment(json["originalAddress"], json["address"], json["amount"],
        json["minAmount"], json["maxAmount"], json["feeMSat"]);
  }
}
