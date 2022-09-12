class PaymentRequest {
  var tag;
  dynamic /* String | null */ callback;
  dynamic /* num | null */ maxSendable;
  dynamic /* num | null */ minSendable;
  dynamic /* String | null */ metadata;
  PaymentRequest(
      [this.tag = "payRequest",
      this.callback,
      this.maxSendable,
      this.minSendable,
      this.metadata]) {}
  static PaymentRequest fromJson(Map<String, dynamic> json) {
    return new PaymentRequest(json["tag"], json["callback"],
        json["maxSendable"], json["minSendable"], json["metadata"]);
  }

  toJson() {
    return {
      "tag": this.tag,
      "callback": this.callback,
      "maxSendable": this.maxSendable,
      "minSendable": this.minSendable,
      "metadata": this.metadata
    };
  }
}
