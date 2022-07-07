class User {
  num id;
  String passHash;
  String firebaseId;
  String lightningAddress;
  User(this.id, this.passHash, this.firebaseId, this.lightningAddress) {}
  static User fromJson(Map<String, dynamic> json) {
    return new User(json["id"], json["passHash"], json["firebaseId"],
        json["lightningAddress"]);
  }
}
