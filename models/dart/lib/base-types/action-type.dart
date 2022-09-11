class ActionType {
  dynamic /* | */ type;
  String originalAddress;
  dynamic /* bool | null */ isLnUrl;
  dynamic /* bool | null */ isLnAddress;
  dynamic /* bool | null */ isBolt11;
  dynamic /* bool | null */ isBolt12;
  dynamic /* bool | null */ isOnChain;
  ActionType(this.type, this.originalAddress,
      [this.isLnUrl = false,
      this.isLnAddress = false,
      this.isBolt11 = false,
      this.isBolt12 = false,
      this.isOnChain = false]) {}
}
