import "address-parse-response.dart" show AddressParseResponse;

class Payment {
  dynamic /* num | null */ potId;
  String originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ currency;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  dynamic /* num | null */ feeMSat;
  AddressParseResponse addressParseResponse;
  Payment(
      this.potId,
      this.originalAddress,
      this.address,
      this.currency,
      this.amount,
      this.minAmount,
      this.maxAmount,
      this.feeMSat,
      this.addressParseResponse) {}
  static Payment fromJson(Map<String, dynamic> json) {
    return new Payment(
        json["potId"],
        json["originalAddress"],
        json["address"],
        json["currency"],
        json["amount"],
        json["minAmount"],
        json["maxAmount"],
        json["feeMSat"],
        AddressParseResponse.fromJson(json["AddressParseResponse"]));
  }
}
