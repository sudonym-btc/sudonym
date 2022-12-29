import "base-class.dart" show BaseClass;
import "bill-split-participant.dart" show BillSplitParticipant;

class BillSplit extends BaseClass {
  dynamic /* num | null */ id;
  dynamic /* num | null */ transactionId;
  String currency;
  dynamic /* num | null */ amount;
  dynamic /* List < BillSplitParticipant > | dynamic */ BillSplitParticipants;
  BillSplit(this.id, this.transactionId,
      [this.currency = "BTC", this.amount = 0, this.BillSplitParticipants])
      : super() {
    /* super call moved to initializer */;
  }
  static BillSplit fromJson(Map<String, dynamic> json) {
    return new BillSplit(
        json["id"],
        json["transactionId"],
        json["currency"],
        json["amount"],
        json["BillSplitParticipants"] != null
            ? json["BillSplitParticipants"]
                .map((i) => BillSplitParticipant.fromJson(i))
                .toList()
            : []);
  }

  dynamic toJson() {
    return {
      "id": this.id,
      "transactionId": this.transactionId,
      "currency": this.currency,
      "amount": this.amount,
      "BillSplitParticipants":
          this.BillSplitParticipants.map((i) => i.toJson()).toList()
    };
  }
}

calcBillSplit(BillSplit billSplit,
    [dynamic /* num | null */ index = null,
    dynamic /* num | null */ amount = null,
    List<num> changedParticipants = const []]) {
  if (index == 0 ||
      billSplit.BillSplitParticipants.length - changedParticipants.length ==
          0) {
    throw "Cannot edit your amount directly";
  }
  if (index != null) {
    if (!changedParticipants.contains(index) &&
        amount != billSplit.BillSplitParticipants[index].amount) {
      changedParticipants.add(index);
    }
    billSplit.BillSplitParticipants[index].amount = amount;
  }
  // Calculate the amount left to pay after all pre-set contributors have been added.
  final amountLeft = calcAmountLeft(billSplit, changedParticipants);
  final amountLeftPerUnchanged = amountLeft /
      (billSplit.BillSplitParticipants.length - changedParticipants.length);
  // Split the remaining amount between the unset participants
  for (var i = 0; i < billSplit.BillSplitParticipants.length; i++) {
    if (!changedParticipants.contains(i)) {
      billSplit.BillSplitParticipants[i].amount = amountLeftPerUnchanged;
    }
  }
}

calcAmountLeft(billSplit, changed) {
  num presetAmounts = 0;
  for (var i = 0; i < billSplit.BillSplitParticipants.length; i++) {
    if (changed.contains(i)) {
      presetAmounts = presetAmounts + billSplit.BillSplitParticipants[i].amount;
    }
  }
  return billSplit.amount - presetAmounts;
}
