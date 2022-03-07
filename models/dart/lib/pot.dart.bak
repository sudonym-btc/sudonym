class Pot {
  String id;
  String userId;
  String name;
  String currency;
  num balance;
  Pot(this.id, this.userId, this.name, this.currency, this.balance) {}
  static fromJson(Map<String, dynamic> json) {
    return new Pot(json["id"], json["userId"], json["name"], json["currency"],
        json["balance"]);
  }
}
