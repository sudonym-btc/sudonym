class AppError extends Error {
  static var code = "";
  AppError() : super() {
    /* super call moved to initializer */;
  }
}

class BalanceLowError extends AppError {
  dynamic /* String | null */ data;
  static var code = "BALANCE_LOW";
  BalanceLowError(this.data) : super() {
    /* super call moved to initializer */;
  }
}

class LNURLProtocolError extends AppError {
  String data;
  static var code = "LNURL_ERROR";
  LNURLProtocolError(this.data) : super() {
    /* super call moved to initializer */;
  }
}

final errors = {
  "LNURLProtocolError": LNURLProtocolError,
  "BalanceLowError": BalanceLowError
};
