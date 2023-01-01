import "base-class.dart" show BaseClass;
import "pot-user.dart" as PotUserModel;

//todo: add polyfill for toList function needed in dart to js too
class Pot extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* String | null */ name;
  dynamic /* String | null */ currency;
  dynamic /* num | null */ balance;
  dynamic /* num | null */ spendableBalance;
  dynamic /* PotUserModel . PotUser | dynamic */ PotUser;
  dynamic /* List < PotUserModel . PotUser > | dynamic */ PotUsers;
  Pot(this.id,
      [this.name = "",
      this.currency = "BTC",
      this.balance = 0,
      this.spendableBalance = 0,
      this.PotUser,
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
        json["PotUser"] != null
            ? PotUserModel.PotUser.fromJson(json["PotUser"])
            : null,
        json["PotUsers"] != null
            ? json["PotUsers"]
                .map((i) => PotUserModel.PotUser.fromJson(i))
                .toList()
            : []);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "currency": this.currency,
      "balance": this.balance,
      "spendableBalance": this.spendableBalance,
      "PotUser": this.PotUser != null ? this.PotUser.toJson() : null,
      "PotUsers": this.PotUsers.map((i) => i.toJson()).toList()
    };
  }
}
