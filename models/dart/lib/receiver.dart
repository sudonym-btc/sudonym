import "base-class.dart" show BaseClass;

class Receiver extends BaseClass {
  num id;
  num potId;
  String type;
  num amount;
  String amountCurrency;
  String data;
  DateTime createdAt;
  Receiver(this.id, this.potId, this.type, this.amount, this.amountCurrency,
      this.data, this.createdAt)
      : super() {
    /* super call moved to initializer */;
  }
  static Receiver fromJson(Map<String, dynamic> json) {
    return new Receiver(json["id"], json["potId"], json["type"], json["amount"],
        json["amountCurrency"], json["data"], DateTime.parse(json["createdAt"]));
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "potId": this.potId,
      "type": this.type,
      "amount": this.amount,
      "amountCurrency": this.amountCurrency,
      "data": this.data,
      "createdAt": this.createdAt
    };
  }
}
