import "base-class.dart" show BaseClass;

class BoltCard extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* String | null */ userId;
  dynamic /* num | null */ senderId;
  dynamic /* String | null */ name;
  dynamic /* String | null */ data;
  BoltCard(this.id, this.userId, this.senderId, this.name, this.data)
      : super() {
    /* super call moved to initializer */;
  }
  static BoltCard fromJson(Map<String, dynamic> json) {
    return new BoltCard(json["id"], json["userId"], json["senderId"],
        json["name"], json["data"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "userId": this.userId,
      "senderId": this.senderId,
      "name": this.name,
      "data": this.data
    };
  }
}
