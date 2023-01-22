class AppError extends Error {
  static var staticCode = "";
  AppError() : super() {
    /* super call moved to initializer */;
  }
}

class BalanceLowError extends AppError {
  static var staticCode = "BALANCE_LOW";
  var code = BalanceLowError.staticCode;
  BalanceLowError() : super() {
    /* super call moved to initializer */;
  }
}

class LNURLProtocolError extends AppError {
  String data;
  static var staticCode = "LNURL_ERROR";
  var code = LNURLProtocolError.staticCode;
  LNURLProtocolError(this.data) : super() {
    /* super call moved to initializer */;
  }
}

final errors = {
  "LNURLProtocolError": LNURLProtocolError,
  "BalanceLowError": BalanceLowError
};
