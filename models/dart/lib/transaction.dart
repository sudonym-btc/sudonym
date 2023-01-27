import "base-class.dart" show BaseClass;
import "bill-split.dart" as BillSplitModel;
import "contact-address.dart" as ContactModel;
import "pot.dart" as PotModel;
import "transaction-tag.dart" as TransactionTagModel;

class Transaction extends BaseClass {
  num id;
  dynamic /* String | null */ onchainId;
  dynamic /* String | null */ invoiceId;
  dynamic /* String | null */ txid;
  dynamic /* String | null */ userId;
  num potId;
  dynamic /* PotModel . Pot | null */ Pot;
  dynamic /* num | null */ receiverId;
  dynamic /* num | null */ senderId;
  bool outgoing;
  dynamic /* String | null */ type;
  dynamic /* num | null */ contactAddressId;
  dynamic /* ContactModel . ContactAddress | null */ ContactAddress;
  dynamic /* List < TransactionTagModel . TransactionTag > | null */ Tags;
  dynamic /* num | null */ billSplitId;
  dynamic /* BillSplitModel . BillSplit | null */ BillSplit;
  dynamic /* String | null */ originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ description;
  dynamic /* String | null */ comment;
  dynamic /* num | null */ transactionId;
  num amount;
  dynamic /* num | null */ totalAmount;
  dynamic /* bool | null */ status;
  dynamic /* String | null */ errorMessage;
  String currencyCode;
  dynamic /* DateTime | null */ createdAt;
  Transaction(
      this.id,
      this.onchainId,
      this.invoiceId,
      this.txid,
      this.userId,
      this.potId,
      this.Pot,
      this.receiverId,
      this.senderId,
      this.outgoing,
      this.type,
      this.contactAddressId,
      this.ContactAddress,
      this.Tags,
      this.billSplitId,
      this.BillSplit,
      this.originalAddress,
      this.address,
      this.description,
      this.comment,
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
        json["userId"],
        json["potId"],
        json["Pot"] != null ? PotModel.Pot.fromJson(json["Pot"]) : null,
        json["receiverId"],
        json["senderId"],
        json["outgoing"],
        json["type"],
        json["contactAddressId"],
        json["ContactAddress"] != null
            ? ContactModel.ContactAddress.fromJson(json["ContactAddress"])
            : null,
        json["Tags"] != null
            ? json["Tags"]
                .map((t) => TransactionTagModel.TransactionTag.fromJson(t))
                .toList()
            : null,
        json["billSplitId"],
        json["BillSplit"] != null
            ? BillSplitModel.BillSplit.fromJson(json["BillSplit"])
            : null,
        json["originalAddress"],
        json["address"],
        json["description"],
        json["comment"],
        json["transactionId"],
        json["amount"],
        json["totalAmount"],
        json["status"],
        json["errorMessage"],
        json["currencyCode"],
        json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "onchainId": this.onchainId,
      "invoiceId": this.invoiceId,
      "txid": this.txid,
      "userId": this.userId,
      "potId": this.potId,
      "Pot": this.Pot,
      "receiverId": this.receiverId,
      "senderId": this.senderId,
      "outgoing": this.outgoing,
      "type": this.type,
      "contactAddressId": this.contactAddressId,
      "ContactAddress": this.ContactAddress,
      "Tags": this.Tags,
      "billSplitId": this.billSplitId,
      "BillSplit": this.BillSplit,
      "originalAddress": this.originalAddress,
      "address": this.address,
      "description": this.description,
      "comment": this.comment,
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
