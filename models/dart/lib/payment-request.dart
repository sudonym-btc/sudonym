class PaymentRequest {
  var tag;
  dynamic /* String | null */ domain;
  dynamic /* String | null */ callback;
  dynamic /* num | null */ maxSendable;
  dynamic /* num | null */ minSendable;
  dynamic /* String | null */ metadata;
  PaymentRequest(
      [this.tag = "payRequest",
      this.domain,
      this.callback,
      this.maxSendable,
      this.minSendable,
      this.metadata]) {}
  static PaymentRequest fromJson(Map<String, dynamic> json) {
    return new PaymentRequest(json["tag"], json["domain"], json["callback"],
        json["maxSendable"], json["minSendable"], json["metadata"]);
  }

  dynamic toJson() {
    return {
      "tag": this.tag,
      "domain": this.domain,
      "callback": this.callback,
      "maxSendable": this.maxSendable,
      "minSendable": this.minSendable,
      "metadata": this.metadata
    };
  }
}
