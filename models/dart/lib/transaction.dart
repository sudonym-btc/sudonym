import "base-class.dart" show BaseClass;

class Transaction extends BaseClass {
  num id;
  dynamic /* String | null */ txid;
  num potId;
  bool outgoing;
  dynamic /* String | null */ type;
  dynamic /* String | null */ originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ description;
  dynamic /* num | null */ transactionId;
  num amount;
  dynamic /* bool | null */ status;
  String currencyCode;
  DateTime createdAt;
  Transaction(
      this.id,
      this.txid,
      this.potId,
      this.outgoing,
      this.type,
      this.originalAddress,
      this.address,
      this.description,
      this.transactionId,
      this.amount,
      this.status,
      this.currencyCode,
      this.createdAt)
      : super() {
    /* super call moved to initializer */;
  }
  static Transaction fromJson(Map<String, dynamic> json) {
    return new Transaction(
        json["id"],
        json["txid"],
        json["potId"],
        json["outgoing"],
        json["type"],
        json["originalAddress"],
        json["address"],
        json["description"],
        json["transactionId"],
        json["amount"],
        json["status"],
        json["currencyCode"],
        DateTime.parse(json["createdAt"]));
  }

  toJson() {
    return {
      "id": this.id,
      "txid": this.txid,
      "potId": this.potId,
      "outgoing": this.outgoing,
      "type": this.type,
      "originalAddress": this.originalAddress,
      "address": this.address,
      "description": this.description,
      "transactionId": this.transactionId,
      "amount": this.amount,
      "status": this.status,
      "currencyCode": this.currencyCode,
      "createdAt": this.createdAt
    };
  }
}
