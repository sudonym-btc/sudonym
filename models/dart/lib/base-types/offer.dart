class Offer {
  String id;
  num potId;
  bool active;
  dynamic /* num | null */ amount;
  String bolt12;
  String bolt12Unsigned;
  Offer(this.id, this.potId, this.active, this.amount, this.bolt12,
      this.bolt12Unsigned) {}
  static Offer fromJson(Map<String, dynamic> json) {
    return new Offer(json["id"], json["potId"], json["active"], json["amount"],
        json["bolt12"], json["bolt12Unsigned"]);
  }
}
