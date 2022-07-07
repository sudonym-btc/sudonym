class UserDevice {
  String uid;
  String token;
  UserDevice(this.uid, this.token) {}
  static UserDevice fromJson(Map<String, dynamic> json) {
    return new UserDevice(json["uid"], json["token"]);
  }
}
