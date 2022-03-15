class User {
  num id;
  String passHash;
  String firebaseId;
  User(this.id, this.passHash, this.firebaseId) {}
  static fromJson(Map<String, dynamic> json) {
    return new User(json["id"], json["passHash"], json["firebaseId"]);
  }
}
