import "base-class.dart" show BaseClass;
import "pot-user.dart" show PotUser;

//todo: add polyfill for toList function needed in dart to js too
class Pot extends BaseClass {
  dynamic /* num | null */ id;
  String name;
  String currency;
  dynamic /* num | null */ balance;
  dynamic /* num | null */ spendableBalance;
  dynamic /* List < PotUser > | dynamic */ PotUsers;
  Pot(this.id,
      [this.name = "",
      this.currency = "BTC",
      this.balance = 0,
      this.spendableBalance = 0,
      this.PotUsers])
      : super() {
    /* super call moved to initializer */;
  }
  static Pot fromJson(Map<String, dynamic> json) {
    return new Pot(
        json["id"],
        json["name"],
        json["currency"],
        json["balance"],
        json["spendableBalance"],
        json["PotUsers"] != null
            ? json["PotUsers"].map((i) => PotUser.fromJson(i)).toList()
            : []);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "currency": this.currency,
      "balance": this.balance,
      "spendableBalance": this.spendableBalance,
      "PotUsers": this.PotUsers.map((i) => i.toJson()).toList()
    };
  }
}
