import "base-class.dart" show BaseClass;

class OnchainTransaction extends BaseClass {
  String id;
  dynamic /* String | null */ fromAddress;
  dynamic /* String | null */ toAddress;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ blockHeight;
  OnchainTransaction(
      this.id, this.fromAddress, this.toAddress, this.amount, this.blockHeight)
      : super() {
    /* super call moved to initializer */;
  }
  static OnchainTransaction fromJson(Map<String, dynamic> json) {
    return new OnchainTransaction(json["id"], json["fromAddress"],
        json["toAddress"], json["amount"], json["blockHeight"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "fromAddress": this.fromAddress,
      "toAddress": this.toAddress,
      "amount": this.amount,
      "blockHeight": this.blockHeight
    };
  }
}
