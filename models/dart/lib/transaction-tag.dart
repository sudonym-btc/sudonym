import "base-class.dart" show BaseClass;

class TransactionTag extends BaseClass {
  num id;
  dynamic /* num | null */ transactionId;
  dynamic /* num | null */ tagId;
  TransactionTag(this.id, this.transactionId, this.tagId) : super() {
    /* super call moved to initializer */;
  }
  static TransactionTag fromJson(Map<String, dynamic> json) {
    return new TransactionTag(json["id"], json["transactionId"], json["tagId"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "transactionId": this.transactionId,
      "tagId": this.tagId
    };
  }
}

final TRANSACTION_TAGS = {1: "roundup"};
