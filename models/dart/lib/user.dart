class User {
  String id;
  String firebaseId;
  User(this.id, this.firebaseId) {}
  static fromJson(Map<String, dynamic> json) {
    return new User(json["id"], json["firebaseId"]);
  }
}
