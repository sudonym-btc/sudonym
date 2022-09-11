import './address-parse-response.dart';
import './payment.dart';
import './base-types/types/currency.dart';

Payment AddressParseResponseToPayment(AddressParseResponse address) {
  if (address.get("success")) {
    if (address.get("isLnUrl") || address.get("isLnAddress")) {
      return Payment({
        "originalAddress": address.get("originalInput"),
        "address": '',
        "amount": address.get("data")['params']['minSendable'] / MSATOSHIS,
        "minAmount": address.get("data")['params']['minSendable'] / MSATOSHIS,
        "maxAmount": address.get("data")['params']['maxSendable'] / MSATOSHIS,
        "fee": null,
        "addressParseResponse": address
      });
    } else if (address.get("isBolt11")) {
      return Payment({
        "originalAddress": address.get("originalInput"),
        "address": '',
        "amount": address.get("data")['msatoshi'] / MSATOSHIS,
        "minAmount": address.get("data")['msatoshi'] / MSATOSHIS,
        "maxAmount": address.get("data")['msatoshi'] / MSATOSHIS,
        "fee": null,
        "addressParseResponse": address
      });
    } else if (address.get("isOnChain")) {}
  }
  throw Error();
}
