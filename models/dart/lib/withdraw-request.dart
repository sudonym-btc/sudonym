class WithdrawRequest {
  var tag;
  dynamic /* String | null */ domain;
  dynamic /* String | null */ callback;
  dynamic /* String | null */ k1;
  dynamic /* String | null */ defaultDescription;
  dynamic /* num | null */ minWithdrawable;
  dynamic /* num | null */ maxWithdrawable;
  WithdrawRequest(
      [this.tag = "withdrawRequest",
      this.domain,
      this.callback,
      this.k1,
      this.defaultDescription,
      this.minWithdrawable,
      this.maxWithdrawable]) {}
  static WithdrawRequest fromJson(Map<String, dynamic> json) {
    return new WithdrawRequest(
        json["tag"],
        json["domain"],
        json["callback"],
        json["k1"],
        json["defaultDescription"],
        json["minWithdrawable"],
        json["maxWithdrawable"]);
  }

  dynamic toJson() {
    return {
      "tag": this.tag,
      "domain": this.domain,
      "callback": this.callback,
      "k1": this.k1,
      "defaultDescription": this.defaultDescription,
      "minWithdrawable": this.minWithdrawable,
      "maxWithdrawable": this.maxWithdrawable
    };
  }
}
