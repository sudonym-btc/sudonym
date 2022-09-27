import "base-class.dart" show BaseClass;

class Transaction extends BaseClass {
  num id;
  dynamic /* String | null */ onchainId;
  dynamic /* String | null */ invoiceId;
  dynamic /* String | null */ txid;
  num potId;
  dynamic /* num | null */ receiverId;
  dynamic /* num | null */ senderId;
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
      this.onchainId,
      this.invoiceId,
      this.txid,
      this.potId,
      this.receiverId,
      this.senderId,
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
        json["onchainId"],
        json["invoiceId"],
        json["txid"],
        json["potId"],
        json["receiverId"],
        json["senderId"],
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

  dynamic toJson() {
    return {
      "id": this.id,
      "onchainId": this.onchainId,
      "invoiceId": this.invoiceId,
      "txid": this.txid,
      "potId": this.potId,
      "receiverId": this.receiverId,
      "senderId": this.senderId,
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
