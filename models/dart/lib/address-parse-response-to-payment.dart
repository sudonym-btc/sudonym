import './address-parse-response.dart';
import './payment.dart';

Payment AddressParseResponseToPayment(AddressParseResponse address) {
  if (address.get("success")) {
    if (address.get("isLnUrl") || address.get("isLnAddress")) {
      return Payment({
        "originalAddress": address.get("originalInput"),
        "address": '',
        "amount": address.get("data")['amount'],
        "minAmount": address.get("data")['minSendable'],
        "maxAmount": address.get("data")['maxSendable'],
        "feeMSat": null
      });
    } else if (address.get("isBolt11")) {
      return Payment({
        "originalAddress": address.get("originalInput"),
        "address": '',
        "amount": address.get("data")['msatoshi'],
        "minAmount": address.get("data")['msatoshi'],
        "maxAmount": address.get("data")['msatoshi'],
        "feeMSat": null
      });
    } else if (address.get("isOnChain")) {}
  }
  throw Error();
}
