import "base-class.dart" show BaseClass;

class BillSplitParticipant extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* num | null */ billSplitId;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ amountPaid;
  dynamic /* bool | null */ paid;
  BillSplitParticipant(this.id, this.billSplitId,
      [this.amount = 0, this.amountPaid = 0, this.paid])
      : super() {
    /* super call moved to initializer */;
  }
  static BillSplitParticipant fromJson(Map<String, dynamic> json) {
    return new BillSplitParticipant(json["id"], json["billSplitId"],
        json["amount"], json["amountPaid"], json["paid"]);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "billSplitId": this.billSplitId,
      "amount": this.amount,
      "amountPaid": this.amountPaid,
      "paid": this.paid
    };
  }
}
