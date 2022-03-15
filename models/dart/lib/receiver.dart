class Receiver {
  String id;
  String potId;
  String type;
  num amount;
  String data;
  DateTime createdAt;
  Receiver(
      this.id, this.potId, this.type, this.amount, this.data, this.createdAt) {}
  static fromJson(Map<String, dynamic> json) {
    return new Receiver(json["id"], json["potId"], json["type"], json["amount"],
        json["data"], DateTime.parse(json["createdAt"]));
  }
}
