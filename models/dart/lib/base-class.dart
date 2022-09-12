class BaseClass {
  toJson() {
    return {};
  }

  static fromJson(dynamic json) {
    return new BaseClass();
  }
}
