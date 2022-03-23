class ContactAddress {
  String contactId;
  String addressType;
  String address;
  String name;
  ContactAddress(this.contactId, this.addressType, this.address, this.name) {}
  static ContactAddress fromJson(Map<String, dynamic> json) {
    return new ContactAddress(
        json["contactId"], json["addressType"], json["address"], json["name"]);
  }
}
