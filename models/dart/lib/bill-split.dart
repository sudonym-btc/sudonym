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
    [dynamic /* BillSplitParticipant | null */ participant = null,
    List<BillSplitParticipant> changedParticipants = const []]) {
  // Just recalc if participant not set
  if (participant == null) {
    final amountLeft = billSplit.amount;
    final amountPerUnchanged =
        amountLeft / billSplit.BillSplitParticipants.length;
    billSplit.BillSplitParticipants
        .forEach((i) => (i.amount = amountPerUnchanged));
    return;
  }
  // Find the participant in the billSplit object
  final contributor = billSplit.BillSplitParticipants
      .firstWhere((contributor) => identical(contributor.id, participant.id));
  // If participant was not found, return
  if (contributor == null) {
    return;
  }
  // Update participant's amount and set the amountChanged flag
  contributor.amount = participant.amount;
  // Update changed participants
  changedParticipants.add(participant);
  final List<BillSplitParticipant> updatedChangedParticipants = [];
  for (final u in changedParticipants) {
    if (updatedChangedParticipants.map((i) => i.id).contains(u.id)) continue;
    updatedChangedParticipants.add(u);
  }
  changedParticipants = updatedChangedParticipants;
  num totalSet = 0;
  // Get the total amount where the amount has been manually set
  changedParticipants.forEach((curr) => (totalSet += curr.amount));
  final amountLeft = billSplit.amount - totalSet;
  final unchangedParticipants = billSplit.BillSplitParticipants
      .where((i) => !changedParticipants.map((u) => u.id).contains(i.id));
  // Update unchanged to divide the rest, or set the first participant to pay rest if all already changed
  if (unchangedParticipants.length == 0) {
    billSplit.BillSplitParticipants[0].amount = amountLeft;
  } else {
    final amountPerUnchanged = amountLeft / unchangedParticipants.length;
    unchangedParticipants.forEach((i) => (i.amount = amountPerUnchanged));
  }
}
