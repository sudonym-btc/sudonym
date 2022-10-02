import "action-type.dart" show ActionType;
import "action-remote-response.dart" show ActionRemoteResponse;
import "payment-request.dart" show PaymentRequest;
import "types.dart" show MSATOSHIS;

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
  dynamic /* String | null */ comment;
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
      this.isOnChain = false,
      this.comment = ""])
      : super("pay", originalAddress, isLnUrl, isLnAddress, isBolt11, isBolt12,
            isOnChain, comment) {
    /* super call moved to initializer */;
  }
  static Payment fromJson(Map<String, dynamic> json) {
    final a = ActionRemoteResponse.fromJson(json["remoteResponse"]);
    return new Payment(
        json["potId"],
        json["originalAddress"],
        json["address"],
        json["currency"],
        json["amount"],
        json["minAmount"]
            ? json["minAmount"]
            : a.data["minSendable"] / MSATOSHIS,
        json["maxAmount"]
            ? json["maxAmount"]
            : a.data["maxSendable"] / MSATOSHIS,
        json["fee"],
        json["feeCurrency"],
        a,
        json["isLnUrl"],
        json["isLnAddress"],
        json["isBolt11"],
        json["isBolt12"],
        json["isOnChain"],
        json["comment"]);
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
          : null,
      "comment": this.comment
    };
  }
}
