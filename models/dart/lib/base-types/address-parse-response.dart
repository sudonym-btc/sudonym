class AddressParseResponse {
  bool success;
  dynamic /* String | null */ message;
  dynamic data;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  AddressParseResponse(this.success, this.message, this.data,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false]) {}
  static AddressParseResponse fromJson(Map<String, dynamic> json) {
    return new AddressParseResponse(
        json["success"],
        json["message"],
        json["data"],
        json["isLnUrl"],
        json["isLnAddress"],
        json["isBolt11"],
        json["isBolt12"],
        json["isOnChain"]);
  }
}
