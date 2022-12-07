class Event {
  dynamic /* String | null */ id;
  String name;
  var data;
  Event(this.id, this.name, this.data) {}
  static Event fromJson(Map<String, dynamic> json) {
    return new Event(json["id"], json["name"], json["data"]);
  }

  dynamic toJson() {
    return {"id": this.id, "name": this.name, "data": this.data};
  }
}
