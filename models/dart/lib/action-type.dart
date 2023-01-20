class ActionType {
  dynamic /* | */ type;
  String originalAddress;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  dynamic /* String | null */ comment;
  ActionType(this.type, this.originalAddress,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false,
      this.comment = ""]) {}
}

class ActionTypeWithAmount extends ActionType {
  dynamic /* | */ type;
  String originalAddress;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  dynamic /* String | null */ comment;
  dynamic /* num | null */ minAmount;
  dynamic /* num | null */ maxAmount;
  dynamic /* num | null */ amount;
  dynamic /* String | null */ currency;
  ActionTypeWithAmount(this.type, this.originalAddress,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false,
      this.comment = "",
      this.minAmount,
      this.maxAmount,
      this.amount,
      this.currency = "BTC"])
      : super(
            "pay",
            originalAddress,
            isLnUrl != null ? isLnUrl : false,
            isLnAddress != null ? isLnAddress : false,
            isBolt11 != null ? isBolt11 : false,
            isBolt12 != null ? isBolt12 : false,
            isOnChain != null ? isOnChain : false,
            comment) {
    /* super call moved to initializer */;
  }
  dynamic toJson() {
    return {
      "type": this.type,
      "originalAddress": this.originalAddress,
      "isLnAddress": this.isLnAddress,
      "isLnUrl": this.isLnUrl,
      "isBolt11": this.isBolt11,
      "isBolt12": this.isBolt12,
      "isOnChain": this.isOnChain,
      "amount": this.amount,
      "comment": this.comment,
      "minAmount": this.minAmount,
      "maxAmount": this.maxAmount,
      "currency": this.currency
    };
  }
}
