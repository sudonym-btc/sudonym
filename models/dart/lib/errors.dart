import "currency-value.dart" as CurrencyValueModel;

class AppError extends Error {
  static var staticCode = "";
  AppError() : super() {
    /* super call moved to initializer */;
  }
  toString() {
    return AppError.staticCode;
  }
}

class BalanceLowError extends AppError {
  CurrencyValueModel.CurrencyValue amount;
  CurrencyValueModel.CurrencyValue amountLeft;
  static var staticCode = "BALANCE_LOW";
  var code = BalanceLowError.staticCode;
  BalanceLowError(this.amount, this.amountLeft) : super() {
    /* super call moved to initializer */;
  }
  static BalanceLowError fromJson(Map<String, dynamic> json) {
    return new BalanceLowError(
        CurrencyValueModel.CurrencyValue.fromJson(json["amount"]),
        CurrencyValueModel.CurrencyValue.fromJson(json["amountLeft"]));
  }

  dynamic toJson() {
    return {
      "code": this.code,
      "amount": this.amount.toJson(),
      "amountLeft": this.amountLeft.toJson()
    };
  }

  toString() {
    return BalanceLowError.staticCode;
  }
}

class LNURLProtocolError extends AppError {
  String data;
  static var staticCode = "LNURL_ERROR";
  var code = LNURLProtocolError.staticCode;
  LNURLProtocolError(this.data) : super() {
    /* super call moved to initializer */;
  }
  static LNURLProtocolError fromJson(Map<String, dynamic> json) {
    return new LNURLProtocolError(json["data"]);
  }

  dynamic toJson() {
    return {"code": this.code, "data": this.data};
  }

  toString() {
    return LNURLProtocolError.staticCode + ": " + this.data;
  }
}

final errors = {
  "LNURLProtocolError": LNURLProtocolError,
  "BalanceLowError": BalanceLowError
};
