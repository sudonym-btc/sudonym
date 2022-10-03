import "withdraw-request.dart" show WithdrawRequest;

class Lnurl {
  String id;
  dynamic /* WithdrawRequest | PaymentRequest */ params;
  Lnurl(this.id, this.params) {}
  static Lnurl fromJson(Map<String, dynamic> json) {
    return new Lnurl(json["id"], json["params"]);
  }

  dynamic toJson() {
    return {"id": this.id, "params": this.params};
  }
}
