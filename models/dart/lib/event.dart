class Event {
  String name;
  var data;
  Event(this.name, this.data) {}
  static Event fromJson(Map<String, dynamic> json) {
    return new Event(json["name"], json["data"]);
  }

  toJson() {
    return {"name": this.name, "data": this.data};
  }
}
