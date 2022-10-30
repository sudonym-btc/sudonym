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
      this.currency])
      : super("pay", originalAddress, isLnUrl, isLnAddress, isBolt11, isBolt12,
            isOnChain, comment) {
    /* super call moved to initializer */;
  }
}
