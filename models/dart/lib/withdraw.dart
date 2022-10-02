import "action-type.dart" show ActionType;
import "action-remote-response.dart" show ActionRemoteResponse;
import "withdraw-request.dart" show WithdrawRequest;
import "types/index.dart" show MSATOSHIS;

class Withdraw extends ActionType {
  dynamic /* num | null */ potId;
  String originalAddress;
  dynamic /* String | null */ currency;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  ActionRemoteResponse<dynamic> remoteResponse;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  dynamic /* String | null */ comment;
  Withdraw(this.potId, this.originalAddress, this.currency, this.amount,
      this.minAmount, this.maxAmount, this.remoteResponse,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false,
      this.comment = ""])
      : super("withdraw", originalAddress, isLnUrl, isLnAddress, isBolt11,
            isBolt12, isOnChain, comment) {
    /* super call moved to initializer */;
  }
  static Withdraw fromJson(Map<String, dynamic> json) {
    final a = ActionRemoteResponse.fromJson(json["remoteResponse"]);
    return new Withdraw(
        json["potId"],
        json["originalAddress"],
        json["currency"],
        json["amount"],
        json["minAmount"] != null
            ? json["minAmount"]
            : a.data["minWithdrawable"] / MSATOSHIS,
        json["maxAmount"] != null
            ? json["maxAmount"]
            : a.data["maxWithdrawable"] / MSATOSHIS,
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
      "currency": this.currency,
      "amount": this.amount,
      "minAmount": this.minAmount,
      "maxAmount": this.maxAmount,
      "remoteResponse": !identical(this.remoteResponse, null)
          ? this.remoteResponse.toJson()
          : null,
      "comment": this.comment
    };
  }
}
