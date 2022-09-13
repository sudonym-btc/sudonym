import "dart:async";
import "../action.dart" show Action;
import "../withdraw-request.dart" show WithdrawRequest;
import "../payment-request.dart" show PaymentRequest;
import "../bolt11.dart" show Bolt11;
import "../action-remote-response.dart" show ActionRemoteResponse;

abstract class IAddressParser {
  Future<Action> parse(String address);
  Future<dynamic /* ActionRemoteResponse< WithdrawRequest > | ActionRemoteResponse< PaymentRequest > */ >
      fetchRemoteLnUrl(String invoice);
  Future<ActionRemoteResponse<PaymentRequest>> fetchRemoteLightningAddress(
      String internetIdentifier);
  Future<ActionRemoteResponse<Bolt11>> fetchBolt11(String invoice);
  getType(String address);
}
