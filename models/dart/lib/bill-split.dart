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

calcBillSplit(
    BillSplit billSplit, dynamic /* BillSplitParticipant | null */ participant,
    [List<BillSplitParticipant> changedParticipants = const []]) {
  // Just recalc if participant not set
  if (!participant || participant == null) {
    final amountLeft = billSplit.amount;
    final amountPerUnchanged =
        amountLeft / billSplit.BillSplitParticipants.length;
    billSplit.BillSplitParticipants
        .forEach((i) => (i.amount = amountPerUnchanged));
    return;
  }
  // Find the participant in the billSplit object
  final contributor = billSplit.BillSplitParticipants
      .find((contributor) => identical(contributor.id, participant.id));
  // If participant was not found, return
  if (!contributor) {
    return;
  }
  // Update participant's amount and set the amountChanged flag
  contributor.amount = participant.amount;
  // Update changed participants
  changedParticipants.add(participant);
  changedParticipants = changedParticipants.reduce((acc, curr) {
    if (acc.map((i) => i.id).includes(curr.id)) return acc;
    acc.add(curr);
    return acc;
  }, []);
  // Get the total amount where the amount has been manually set
  final totalSet = changedParticipants
      .map((i) => i.amount)
      .reduce((acc, curr) => acc + curr, 0);
  final amountLeft = billSplit.amount - totalSet;
  final unchangedParticipants = billSplit.BillSplitParticipants
      .filter((i) => !changedParticipants.map((u) => u.id).includes(i.id));
  console.log(amountLeft);
  console.log(unchangedParticipants);
  // Update unchanged to divide the rest, or set the first participant to pay rest if all already changed
  if (!unchangedParticipants.length) {
    billSplit.BillSplitParticipants[0].amount = amountLeft;
  } else {
    final amountPerUnchanged = amountLeft / unchangedParticipants.length;
    unchangedParticipants.forEach((i) => (i.amount = amountPerUnchanged));
  }
}
