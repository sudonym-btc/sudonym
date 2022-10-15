import "base-class.dart" show BaseClass;

class ContactAddress extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* num | null */ contactId;
  dynamic /* String | null */ addressType;
  dynamic /* String | null */ address;
  dynamic /* String | null */ name;
  ContactAddress(
      this.id, this.contactId, this.addressType, this.address, this.name)
      : super() {
    /* super call moved to initializer */;
  }
  static ContactAddress fromJson(Map<String, dynamic> json) {
    return new ContactAddress(json["id"], json["contactId"],
        json["addressType"], json["address"], json["name"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "contactId": this.contactId,
      "addressType": this.addressType,
      "address": this.address,
      "name": this.name
    };
  }
}
