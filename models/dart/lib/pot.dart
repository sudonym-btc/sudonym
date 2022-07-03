class Pot {
  num id;
  String name;
  String currency;
  num balance;
  num spendableBalance;
  Pot(this.id, this.name, this.currency, this.balance, this.spendableBalance) {}
  static Pot fromJson(Map<String, dynamic> json) {
    return new Pot(json["id"], json["name"], json["currency"], json["balance"],
        json["spendableBalance"]);
  }
}
