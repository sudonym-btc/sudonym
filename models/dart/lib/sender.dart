import "base-class.dart" show BaseClass;

class Sender extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* String | null */ userId;
  dynamic /* num | null */ potId;
  dynamic /* String | null */ lnurlId;
  dynamic /* String | null */ type;
  dynamic /* num | null */ amount;
  dynamic /* String | null */ amountCurrency;
  dynamic /* num | null */ limitDay;
  dynamic /* num | null */ limitMonth;
  dynamic /* num | null */ limitYear;
  dynamic /* num | null */ limitMin;
  dynamic /* num | null */ limitMax;
  String data;
  dynamic /* DateTime | null */ createdAt;
  Sender(
      this.id,
      this.userId,
      this.potId,
      this.lnurlId,
      this.type,
      this.amount,
      this.amountCurrency,
      this.limitDay,
      this.limitMonth,
      this.limitYear,
      this.limitMin,
      this.limitMax,
      this.data,
      this.createdAt)
      : super() {
    /* super call moved to initializer */;
  }
  static Sender fromJson(Map<String, dynamic> json) {
    return new Sender(
        json["id"],
        json["userId"],
        json["potId"],
        json["lnurlId"],
        json["type"],
        json["amount"],
        json["amountCurrency"],
        json["limitDay"],
        json["limitMonth"],
        json["limitYear"],
        json["limitMin"],
        json["limitMax"],
        json["data"],
        DateTime.parse(json["createdAt"]));
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "userId": this.userId,
      "potId": this.potId,
      "lnurlId": this.lnurlId,
      "type": this.type,
      "amount": this.amount,
      "amountCurrency": this.amountCurrency,
      "limitDay": this.limitDay,
      "limitMonth": this.limitMonth,
      "limitYear": this.limitYear,
      "limitMin": this.limitMin,
      "limitMax": this.limitMax,
      "data": this.data,
      "createdAt": this.createdAt
    };
  }
}
