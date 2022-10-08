import "base-class.dart" show BaseClass;

class Offer extends BaseClass {
  String id;
  num potId;
  bool active;
  dynamic /* num | null */ amount;
  String bolt12;
  String bolt12Unsigned;
  Offer(this.id, this.potId, this.active, this.amount, this.bolt12,
      this.bolt12Unsigned)
      : super() {
    /* super call moved to initializer */;
  }
  static Offer fromJson(Map<String, dynamic> json) {
    return new Offer(json["id"], json["potId"], json["active"], json["amount"],
        json["bolt12"], json["bolt12Unsigned"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "potId": this.potId,
      "active": this.active,
      "amount": this.amount,
      "bolt12": this.bolt12,
      "bolt12Unsigned": this.bolt12Unsigned
    };
  }
}
