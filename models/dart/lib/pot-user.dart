import "base-class.dart" show BaseClass;

class PotUser extends BaseClass {
  num id;
  num potId;
  num userId;
  PotUser(this.id, this.potId, this.userId) : super() {
    /* super call moved to initializer */;
  }
  static PotUser fromJson(Map<String, dynamic> json) {
    return new PotUser(json["id"], json["potId"], json["userId"]);
  }

  dynamic toJson() {
    return {"id": this.id, "potId": this.potId, "userId": this.userId};
  }
}
