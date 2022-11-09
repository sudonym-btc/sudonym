import "base-class.dart" show BaseClass;

const LIGHTNINGADDRESSREGEX = "^[a-z0-9_\\-\\.]+";

class User extends BaseClass {
  String id;
  String firebaseId;
  dynamic /* String | null */ lightningAddress;
  User(this.id, this.firebaseId, this.lightningAddress) : super() {
    /* super call moved to initializer */;
  }
  static User fromJson(Map<String, dynamic> json) {
    return new User(json["id"], json["firebaseId"], json["lightningAddress"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "firebaseId": this.firebaseId,
      "lightningAddress": this.lightningAddress
    };
  }
}
