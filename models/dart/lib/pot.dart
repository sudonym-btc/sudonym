import "base-class.dart" show BaseClass;

class Pot extends BaseClass {
  num id;
  String name;
  String currency;
  num balance;
  num spendableBalance;
  Pot(this.id, this.name, this.currency, this.balance, this.spendableBalance)
      : super() {
    /* super call moved to initializer */;
  }
  static Pot fromJson(dynamic json) {
    return new Pot(json["id"], json["name"], json["currency"], json["balance"],
        json["spendableBalance"]);
  }

  toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "currency": this.currency,
      "balance": this.balance,
      "spendableBalance": this.spendableBalance
    };
  }
}
