import "base-class.dart" show BaseClass;

class Pot extends BaseClass {
  dynamic /* num | null */ id;
  String name;
  String currency;
  dynamic /* num | null */ balance;
  dynamic /* num | null */ spendableBalance;
  Pot(this.id,
      [this.name = "",
      this.currency = "BTC",
      this.balance = 0,
      this.spendableBalance = 0])
      : super() {
    /* super call moved to initializer */;
  }
  static Pot fromJson(Map<String, dynamic> json) {
    return new Pot(json["id"], json["name"], json["currency"], json["balance"],
        json["spendableBalance"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "currency": this.currency,
      "balance": this.balance,
      "spendableBalance": this.spendableBalance
    };
  }
}
