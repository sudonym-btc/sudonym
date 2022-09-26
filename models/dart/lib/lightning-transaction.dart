import "base-class.dart" show BaseClass;

class LightningTransaction extends BaseClass {
  String id;
  String preimage;
  dynamic /* num | null */ amount;
  dynamic /* bool | null */ status;
  LightningTransaction(this.id, this.preimage, this.amount, this.status)
      : super() {
    /* super call moved to initializer */;
  }
  static LightningTransaction fromJson(Map<String, dynamic> json) {
    return new LightningTransaction(
        json["id"], json["preimage"], json["amount"], json["status"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "preimage": this.preimage,
      "amount": this.amount,
      "status": this.status
    };
  }
}
