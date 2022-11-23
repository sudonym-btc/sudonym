import "base-class.dart" show BaseClass;

class PotUser extends BaseClass {
  num id;
  num index;
  num potId;
  String userId;
  PotUser(this.id, this.index, this.potId, this.userId) : super() {
    /* super call moved to initializer */;
  }
  static PotUser fromJson(Map<String, dynamic> json) {
    return new PotUser(
        json["id"], json["index"], json["potId"], json["userId"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "index": this.index,
      "potId": this.potId,
      "userId": this.userId
    };
  }
}
