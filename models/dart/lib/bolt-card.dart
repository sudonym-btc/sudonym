import "base-class.dart" show BaseClass;
import "sender.dart" show Sender;

class BoltCard extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* String | null */ userId;
  dynamic /* num | null */ senderId;
  dynamic /* Sender | null */ sender;
  dynamic /* String | null */ name;
  dynamic /* num | null */ written;
  BoltCard(
      this.id, this.userId, this.senderId, this.sender, this.name, this.written)
      : super() {
    /* super call moved to initializer */;
  }
  static BoltCard fromJson(Map<String, dynamic> json) {
    return new BoltCard(
        json["id"],
        json["userId"],
        json["senderId"],
        json["sender"] != null ? Sender.fromJson(json["sender"]) : null,
        json["name"],
        json["written"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "userId": this.userId,
      "senderId": this.senderId,
      "sender": this.sender != null ? this.sender.toJson() : null,
      "name": this.name,
      "written": this.written
    };
  }
}
