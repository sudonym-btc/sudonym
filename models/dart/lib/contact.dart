import "base-class.dart" show BaseClass;
import "contact-address.dart" show ContactAddress;

class Contact extends BaseClass {
  num id;
  String userId;
  String name;
  List<ContactAddress> ContactAddresses;
  Contact(this.id, this.userId, this.name, this.ContactAddresses) : super() {
    /* super call moved to initializer */;
  }
  static Contact fromJson(Map<String, dynamic> json) {
    final List<ContactAddress> addresses = [];
    json["ContactAddresses"].forEach((e) {
      addresses.add(ContactAddress.fromJson(e));
    });
    return new Contact(json["id"], json["userId"], json["name"], addresses);
  }

  dynamic toJson() {
    final List<Map<String, dynamic>> addresses = [];
    this.ContactAddresses.forEach((e) {
      addresses.add(e.toJson());
    });
    return {
      "id": this.id,
      "userId": this.userId,
      "name": this.name,
      "ContactAddresses": addresses
    };
  }
}
