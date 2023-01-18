import "action-remote-response.dart" show ActionRemoteResponse;
import "action-type.dart" show ActionTypeWithAmount;
import "types/index.dart" show MSATOSHIS, SATOSHIS;

class Payment extends ActionTypeWithAmount {
  dynamic /* num | null */ potId;
  String originalAddress;
  dynamic /* String | null */ address;
  dynamic /* String | null */ currency;
  dynamic /* num | null */ amount;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  dynamic /* num | null */ fee;
  dynamic /* String | null */ feeCurrency;
  dynamic /* List < ActionRemoteResponse< dynamic > > | dynamic */ remoteResponses;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  dynamic /* String | null */ comment;
  dynamic /* String | null */ description;
  dynamic /* num | null */ commentAllowed;
  Payment(this.potId, this.originalAddress, this.address, this.currency,
      this.amount, this.minAmount, this.maxAmount, this.fee,
      [this.feeCurrency = "BTC",
      this.remoteResponses,
      this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false,
      this.comment = "",
      this.description = "",
      this.commentAllowed])
      : super("pay", originalAddress, isLnUrl, isLnAddress, isBolt11, isBolt12,
            isOnChain, comment, minAmount, maxAmount, amount, currency) {
    /* super call moved to initializer */;
  }
  static Payment fromJson(Map<String, dynamic> json) {
    print(json);
    final a = json["remoteResponses"] != null
        ? json["remoteResponses"]
            .map((e) => ActionRemoteResponse.fromJson(e))
            .toList()
        : null;
    final p = new Payment(
        json["potId"],
        json["originalAddress"],
        json["address"],
        json["currency"] != null ? json["currency"] : "BTC",
        json["amount"],
        json["minAmount"],
        json["maxAmount"],
        json["fee"],
        json["feeCurrency"],
        a,
        json["isLnUrl"],
        json["isLnAddress"],
        json["isBolt11"],
        json["isBolt12"],
        json["isOnChain"],
        json["comment"],
        json["description"],
        json["commentAllowed"]);
    final remoteResponse = p.remoteResponses[p.remoteResponses.length - 1];
    if (remoteResponse != null) {
      if (p.isBolt11) {
        final sats = remoteResponse.data["satoshis"] != null
            ? remoteResponse.data["satoshis"]
            : remoteResponse.data["millisatoshis"] != null
                ? remoteResponse.data["millisatoshis"] / 1000
                : null;
        if (sats != null) {
          p.minAmount = sats / SATOSHIS;
          p.maxAmount = sats / SATOSHIS;
        }
      } else if (p.isLnUrl) {
        if (remoteResponse.success) {
          p.minAmount = remoteResponse.data["minSendable"] / MSATOSHIS;
          p.maxAmount = remoteResponse.data["maxSendable"] / MSATOSHIS;
        }
      }
      // Minimum value of 1 satoshi to send
      p.minAmount = p.minAmount > 1 / SATOSHIS ? p.minAmount : 1 / SATOSHIS;
      if (p.amount == null && p.minAmount == p.maxAmount) {
        p.amount = p.minAmount;
      }
    }
    print('AFTRER');
    print(p.fee);
    return p;
  }

  dynamic toJson() {
    return {
      "type": this.type,
      "potId": this.potId,
      "originalAddress": this.originalAddress,
      "address": this.address,
      "currency": this.currency,
      "amount": this.amount,
      "minAmount": this.minAmount,
      "maxAmount": this.maxAmount,
      "fee": this.fee,
      "feeCurrency": this.feeCurrency,
      "remoteResponses": !identical(this.remoteResponses, null)
          ? this.remoteResponses.map((e) => e.toJson()).toList()
          : null,
      "comment": this.comment,
      "description": this.description,
      "commentAllowed": this.commentAllowed
    };
  }
}
