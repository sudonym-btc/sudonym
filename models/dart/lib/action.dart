import "action-type.dart" show ActionType;
import "payment.dart" show Payment;
import "withdraw.dart" show Withdraw;

class Action extends ActionType {
  dynamic /* | */ type;
  String originalAddress;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  Action(this.type, this.originalAddress,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false])
      : super(type, originalAddress, isLnUrl, isLnAddress, isBolt11, isBolt12,
            isOnChain) {
    /* super call moved to initializer */;
  }
  static Action fromJson(Map<String, dynamic> json) {
    return new Action(
        json["type"],
        json["originalAddress"],
        json["isLnUrl"],
        json["isLnAddress"],
        json["isBolt11"],
        json["isBolt12"],
        json["isOnChain"]);
  }

  static dynamic /* Payment | Withdraw */ from(json) {
    if (json["type"] == "payment") return Payment.fromJson(json);
    return Withdraw.fromJson(json);
  }

  dynamic toJson() {
    return {
      "type": this.type,
      "originalAddress": this.originalAddress,
      "isLnUrl": this.isLnUrl,
      "isLnAddress": this.isLnAddress,
      "isBolt11": this.isBolt11,
      "isBolt12": this.isBolt12,
      "isOnChain": this.isOnChain
    };
  }
}
