import "action-type.dart" show ActionType;
import "action-remote-response.dart" show ActionRemoteResponse;
import "withdraw-request.dart" show WithdrawRequest;

class Withdraw extends ActionType {
  dynamic /* num | null */ potId;
  String originalAddress;
  dynamic /* String | null */ currency;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  ActionRemoteResponse<dynamic> remoteResponse;
  Withdraw(this.potId, this.originalAddress, this.currency, this.amount,
      this.minAmount, this.maxAmount, this.remoteResponse)
      : super("withdraw", originalAddress) {
    /* super call moved to initializer */;
  }
  static Withdraw fromJson(Map<String, dynamic> json) {
    return new Withdraw(
        json["potId"],
        json["originalAddress"],
        json["currency"],
        json["amount"],
        json["minAmount"],
        json["maxAmount"],
        ActionRemoteResponse.fromJson(json["remoteResponse"]));
  }
}
