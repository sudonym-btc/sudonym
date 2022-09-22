import "withdraw.dart" show Withdraw;
import "payment.dart" show Payment;
import "action.dart" show Action;

class ActionParseResponse {
  dynamic /* Payment | null */ payment;
  dynamic /* Withdraw | null */ withdraw;
  ActionParseResponse([this.payment, this.withdraw]) {}
  static from(dynamic a) {
    switch (a["type"]) {
      case "pay":
        return new ActionParseResponse(Payment.fromJson(a), null);
      case "withdraw":
        return new ActionParseResponse(null, Withdraw.fromJson(a));
    }
  }

  static fromJson(dynamic json) {
    if (json["payment"] != null) {
      return new ActionParseResponse(Payment.fromJson(json["payment"]), null);
    } else if (json["withdraw"] != null) {
      return new ActionParseResponse(null, Withdraw.fromJson(json["withdraw"]));
    }
  }
}
