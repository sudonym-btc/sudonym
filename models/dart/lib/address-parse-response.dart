import "payment.dart" show Payment;

class AddressParseResponse {
  dynamic /* String | null */ originalInput;
  bool success;
  dynamic /* String | null */ message;
  dynamic data;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  AddressParseResponse(
      this.originalInput, this.success, this.message, this.data,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false]) {}
  static AddressParseResponse fromJson(Map<String, dynamic> json) {
    return new AddressParseResponse(
        json["originalInput"],
        json["success"],
        json["message"],
        json["data"],
        json["isLnUrl"],
        json["isLnAddress"],
        json["isBolt11"],
        json["isBolt12"],
        json["isOnChain"]);
  }

  Payment toPayment() {
    if (this.success) {
      print(this);
      if (this.isLnUrl || this.isLnAddress) {
        return new Payment(this.originalInput, "", this.data["amount"],
            this.data["minSendable"], this.data["maxSendable"], null);
      } else if (this.isBolt11) {
        num? amount =
            this.data['msatoshi'] != null ? this.data["msatoshi"] / 1000 : null;
        return new Payment(
            this.originalInput, "", amount, amount, amount, null);
      } else if (this.isOnChain) {}
    }
    throw Error();
  }
}
