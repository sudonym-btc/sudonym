import "base-class.dart" show BaseClass;
import "contact-address.dart" as Model;
import "pot.dart" as PotModel;

class Transaction extends BaseClass {
  num id;
  dynamic /* String | null */ onchainId;
  dynamic /* String | null */ invoiceId;
  dynamic /* String | null */ txid;
  num potId;
  dynamic /* PotModel . Pot | null */ Pot;
  dynamic /* num | null */ receiverId;
  dynamic /* num | null */ senderId;
  bool outgoing;
  dynamic /* String | null */ type;
  dynamic /* num | null */ contactAddressId;
  dynamic /* Model . ContactAddress | null */ ContactAddress;
  dynamic /* String | null */ originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ description;
  dynamic /* num | null */ transactionId;
  num amount;
  num totalAmount;
  dynamic /* bool | null */ status;
  dynamic /* String | null */ errorMessage;
  String currencyCode;
  DateTime createdAt;
  Transaction(
      this.id,
      this.onchainId,
      this.invoiceId,
      this.txid,
      this.potId,
      this.Pot,
      this.receiverId,
      this.senderId,
      this.outgoing,
      this.type,
      this.contactAddressId,
      this.ContactAddress,
      this.originalAddress,
      this.address,
      this.description,
      this.transactionId,
      this.amount,
      this.totalAmount,
      this.status,
      this.errorMessage,
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
        json["Pot"] != null ? PotModel.Pot.fromJson(json["Pot"]) : null,
        json["receiverId"],
        json["senderId"],
        json["outgoing"],
        json["type"],
        json["contactAddressId"],
        json["ContactAddress"] != null
            ? Model.ContactAddress.fromJson(json["ContactAddress"])
            : null,
        json["originalAddress"],
        json["address"],
        json["description"],
        json["transactionId"],
        json["amount"],
        json["totalAmount"],
        json["status"],
        json["errorMessage"],
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
      "Pot": this.Pot,
      "receiverId": this.receiverId,
      "senderId": this.senderId,
      "outgoing": this.outgoing,
      "type": this.type,
      "contactAddressId": this.contactAddressId,
      "ContactAddress": this.ContactAddress,
      "originalAddress": this.originalAddress,
      "address": this.address,
      "description": this.description,
      "transactionId": this.transactionId,
      "amount": this.amount,
      "totalAmount": this.amount,
      "status": this.status,
      "errorMessage": this.errorMessage,
      "currencyCode": this.currencyCode,
      "createdAt": this.createdAt
    };
  }
}
