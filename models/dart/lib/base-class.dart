class BaseClass {
  dynamic toJson() {
    return {};
  }

  static fromJson(dynamic json) {
    return new BaseClass();
  }
}
