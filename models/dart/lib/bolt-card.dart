import "base-class.dart" show BaseClass;
import "sender.dart" as Model;

class BoltCard extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* String | null */ userId;
  dynamic /* num | null */ senderId;
  dynamic /* Model . Sender | null */ Sender;
  dynamic /* String | null */ name;
  dynamic /* num | null */ written;
  BoltCard(
      this.id, this.userId, this.senderId, this.Sender, this.name, this.written)
      : super() {
    /* super call moved to initializer */;
  }
  static BoltCard fromJson(Map<String, dynamic> json) {
    return new BoltCard(
        json["id"],
        json["userId"],
        json["senderId"],
        json["Sender"] != null ? Model.Sender.fromJson(json["Sender"]) : null,
        json["name"],
        json["written"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "userId": this.userId,
      "senderId": this.senderId,
      "Sender": this.Sender != null ? this.Sender.toJson() : null,
      "name": this.name,
      "written": this.written
    };
  }
}
