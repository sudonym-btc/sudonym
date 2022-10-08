import "base-class.dart" show BaseClass;

class ContactAddress extends BaseClass {
  num contactId;
  String addressType;
  String address;
  String name;
  ContactAddress(this.contactId, this.addressType, this.address, this.name)
      : super() {
    /* super call moved to initializer */;
  }
  static ContactAddress fromJson(Map<String, dynamic> json) {
    return new ContactAddress(
        json["contactId"], json["addressType"], json["address"], json["name"]);
  }

  dynamic toJson() {
    return {
      "contactId": this.contactId,
      "addressType": this.addressType,
      "address": this.address,
      "name": this.name
    };
  }
}
