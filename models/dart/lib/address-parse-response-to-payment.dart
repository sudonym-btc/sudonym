import './address-parse-response.dart';
import './payment.dart';

Payment AddressParseResponseToPayment(AddressParseResponse address) {
  if (address.get("success")) {
    if (address.get("isLnUrl") || address.get("isLnAddress")) {
      return Payment({
        "originalAddress": address.get("originalInput"),
        "address": '',
        "amount": address.get("data")['params']['minSendable'],
        "minAmount": address.get("data")['params']['minSendable'],
        "maxAmount": address.get("data")['params']['maxSendable'],
        "feeMSat": null,
        "addressParseResponse": address
      });
    } else if (address.get("isBolt11")) {
      return Payment({
        "originalAddress": address.get("originalInput"),
        "address": '',
        "amount": address.get("data")['msatoshi'],
        "minAmount": address.get("data")['msatoshi'],
        "maxAmount": address.get("data")['msatoshi'],
        "feeMSat": null,
        "addressParseResponse": address
      });
    } else if (address.get("isOnChain")) {}
  }
  throw Error();
}
