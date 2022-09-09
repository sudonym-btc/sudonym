class User {
  String id;
  String firebaseId;
  String lightningAddress;
  User(this.id, this.firebaseId, this.lightningAddress) {}
  static User fromJson(Map<String, dynamic> json) {
    return new User(json["id"], json["firebaseId"], json["lightningAddress"]);
  }
}
