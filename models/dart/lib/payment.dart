class Payment {
  String originalAddress;
  dynamic /* String | null */ address;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ feeMSat;
  Payment(this.originalAddress, this.address, this.amount, this.feeMSat) {}
  static Payment fromJson(Map<String, dynamic> json) {
    return new Payment(json["originalAddress"], json["address"], json["amount"],
        json["feeMSat"]);
  }
}
