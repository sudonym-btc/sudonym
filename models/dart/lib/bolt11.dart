class Bolt11 {
  num millisatoshis;
  dynamic network;
  String payeeNodeKey;
  String paymentRequest;
  String prefix;
  num recoveryFlag;
  num satoshis;
  String signature;
  List<dynamic> tags;
  num timeExpireDate;
  String timeExpireDateString;
  num timestamp;
  String timestampString;
  String wordsTemp;
  Bolt11(
      this.millisatoshis,
      this.network,
      this.payeeNodeKey,
      this.paymentRequest,
      this.prefix,
      this.recoveryFlag,
      this.satoshis,
      this.signature,
      this.tags,
      this.timeExpireDate,
      this.timeExpireDateString,
      this.timestamp,
      this.timestampString,
      this.wordsTemp) {}
  static Bolt11 fromJson(Map<String, dynamic> json) {
    return new Bolt11(
        json["millisatoshis"],
        json["network"],
        json["payeeNodeKey"],
        json["paymentRequest"],
        json["prefix"],
        json["recoveryFlag"],
        json["satoshis"],
        json["signature"],
        json["tags"],
        json["timeExpireDate"],
        json["timeExpireDateString"],
        json["timestamp"],
        json["timestampString"],
        json["wordsTemp"]);
  }

  toJson() {
    return {
      "millisatoshis": this.millisatoshis,
      "network": this.network,
      "payeeNodeKey": this.payeeNodeKey,
      "paymentRequest": this.paymentRequest,
      "prefix": this.prefix,
      "recoveryFlag": this.recoveryFlag,
      "satoshis": this.satoshis,
      "signature": this.signature,
      "tags": this.tags,
      "timeExpireDate": this.timeExpireDate,
      "timeExpireDateString": this.timeExpireDateString,
      "timestamp": this.timestamp,
      "timestampString": this.timestampString,
      "wordsTemp": this.wordsTemp
    };
  }
}
