import 'package:bech32/bech32.dart';
import 'package:reactive_forms/reactive_forms.dart';

const LIGHTNING_SCHEME = 'lightning';
const BOLT11_SCHEME = 'lnbc';
const LNURL_SCHEME = 'lnurl';

RegExp BITCOIN_PATTERN = RegExp(
    '\b(bc(0([ac-hj-np-z02-9]{39}|[ac-hj-np-z02-9]{59})|1[ac-hj-np-z02-9]{8,87})|[13][a-km-zA-HJ-NP-Z1-9]{25,35})\b');
RegExp BITCOIN_PATTERN_TEST = RegExp(
    '\b((bc|tb)(0([ac-hj-np-z02-9]{39}|[ac-hj-np-z02-9]{59})|1[ac-hj-np-z02-9]{8,87})|([13]|[mn2])[a-km-zA-HJ-NP-Z1-9]{25,39})\b');

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension URLValidator on String {
  bool isValidUrl() {
    var urlPattern =
        r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    return RegExp(urlPattern, caseSensitive: false).hasMatch(this);
  }
}

bool isOnchainAddress(String addr) {
  return BITCOIN_PATTERN.hasMatch(addr);
}

bool isLnUrl(String addr) {
  try {
    Bech32Codec codec = Bech32Codec();
    Bech32 bech32 = codec.decode(
      addr,
      addr.length,
    );
    print("hrp: ${bech32.hrp}");
    print(addr.isValidEmail());
  } catch (e) {
    return false;
  }
  return true;
  // => hrp: lnbc
}

bool isValidAddress(String addr) {
  return isOnchainAddress(addr) || isLnUrl(addr) || addr.isValidEmail();
}

Map<String, dynamic>? isValidAddressValidator(AbstractControl control) {
  return isValidAddress(control.value)
      ? null
      : <String, dynamic>{
          'Must be a valid lightning, onchain or lnurl address': control.value
        };
}
