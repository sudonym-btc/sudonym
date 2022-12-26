import "base-class.dart" show BaseClass;

class Receiver extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* num | null */ parentId;
  num potId;
  String type;
  num amount;
  String amountCurrency;
  dynamic /* String | null */ data;
  dynamic /* String | null */ lnurlId;
  dynamic /* String | null */ description;
  dynamic /* String | null */ comment;
  dynamic /* dynamic | null */ payerData;
  dynamic /* num | null */ received;
  dynamic /* DateTime | null */ createdAt;
  Receiver(
      this.id,
      this.parentId,
      this.potId,
      this.type,
      this.amount,
      this.amountCurrency,
      this.data,
      this.lnurlId,
      this.description,
      this.comment,
      this.payerData,
      this.received,
      this.createdAt)
      : super() {
    /* super call moved to initializer */;
  }
  static Receiver fromJson(Map<String, dynamic> json) {
    return new Receiver(
        json["id"],
        json["parentId"],
        json["potId"],
        json["type"],
        json["amount"],
        json["amountCurrency"],
        json["data"],
        json["lnurlId"],
        json["description"],
        json["comment"],
        json["payerData"],
        json["received"],
        json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "parentId": this.parentId,
      "potId": this.potId,
      "type": this.type,
      "amount": this.amount,
      "amountCurrency": this.amountCurrency,
      "data": this.data,
      "lnurlId": this.lnurlId,
      "description": this.description,
      "comment": this.comment,
      "payerData": this.payerData,
      "received": this.received,
      "createdAt": this.createdAt
    };
  }
}
