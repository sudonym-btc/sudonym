import "contact-address.dart" show ContactAddress;

class Contact {
  String id;
  String userId;
  String name;
  List<ContactAddress> ContactAddresses;
  Contact(this.id, this.userId, this.name, this.ContactAddresses) {}
  static Contact fromJson(Map<String, dynamic> json) {
    List<ContactAddress> addresses = [];
    json["ContactAddresses"].forEach((e) {
      addresses.add(ContactAddress.fromJson(e));
    });
    return new Contact(json["id"], json["userId"], json["name"], addresses);
  }
}
