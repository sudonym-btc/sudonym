import "base-class.dart" show BaseClass;

class UserDevice extends BaseClass {
  String uid;
  String token;
  UserDevice(this.uid, this.token) : super() {
    /* super call moved to initializer */;
  }
  static UserDevice fromJson(Map<String, dynamic> json) {
    return new UserDevice(json["uid"], json["token"]);
  }

  dynamic toJson() {
    return {"uid": this.uid, "token": this.token};
  }
}
