import "bolt11.dart" show Bolt11;
import "withdraw-request.dart" show WithdrawRequest;
import "payment-request.dart" show PaymentRequest;

class ActionRemoteResponse<T> {
  bool success;
  dynamic /* String | null */ message;
  dynamic /* T | null */ data;
  ActionRemoteResponse([this.success = true, this.message, this.data]) {}
  static ActionRemoteResponse<dynamic> fromJson(Map<String, dynamic> json) {
    return new ActionRemoteResponse(
        json["success"], json["message"], json["data"]);
  }
}
