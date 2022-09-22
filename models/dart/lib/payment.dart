import "action-type.dart" show ActionType;
import "action-remote-response.dart" show ActionRemoteResponse;
import "payment-request.dart" show PaymentRequest;

class Payment extends ActionType {
  dynamic /* num | null */ potId;
  String originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ currency;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  dynamic /* num | null */ fee;
  dynamic /* String | null */ feeCurrency;
  ActionRemoteResponse<dynamic> remoteResponse;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  Payment(
      this.potId,
      this.originalAddress,
      this.address,
      this.currency,
      this.amount,
      this.minAmount,
      this.maxAmount,
      this.fee,
      this.feeCurrency,
      this.remoteResponse,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false])
      : super("pay", originalAddress, isLnUrl, isLnAddress, isBolt11, isBolt12,
            isOnChain) {
    /* super call moved to initializer */;
  }
  static Payment fromJson(Map<String, dynamic> json) {
    return new Payment(
        json["potId"],
        json["originalAddress"],
        json["address"],
        json["currency"],
        json["amount"],
        json["minAmount"],
        json["maxAmount"],
        json["fee"],
        json["feeCurrency"],
        ActionRemoteResponse.fromJson(json["remoteResponse"]),
        json["isLnUrl"],
        json["isLnAddress"],
        json["isBolt11"],
        json["isBolt12"],
        json["isOnChain"]);
  }

  dynamic toJson() {
    return {
      "type": this.type,
      "potId": this.potId,
      "originalAddress": this.originalAddress,
      "address": this.address,
      "currency": this.currency,
      "amount": this.amount,
      "minAmount": this.minAmount,
      "maxAmount": this.maxAmount,
      "fee": this.fee,
      "feeCurrency": this.feeCurrency,
      "remoteResponse": !identical(this.remoteResponse, null)
          ? this.remoteResponse.toJson()
          : null
    };
  }
}
