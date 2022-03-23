class PotUser {
  num id;
  num potId;
  num userId;
  PotUser(this.id, this.potId, this.userId) {}
  static PotUser fromJson(Map<String, dynamic> json) {
    return new PotUser(json["id"], json["potId"], json["userId"]);
  }
}
