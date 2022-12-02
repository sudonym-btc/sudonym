import 'package:bech32/bech32.dart';
import 'package:reactive_forms/reactive_forms.dart';

const LIGHTNING_SCHEME = 'lightning';
const BOLT11_SCHEME = 'lnbc';
const LNURL_SCHEME = 'lnurl';

final RegExp BITCOIN_PATTERN = RegExp(r'^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}');
final RegExp BITCOIN_PATTERN_TEST = RegExp(
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
        r'(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?';
    return RegExp(urlPattern, caseSensitive: false).hasMatch(this);
  }
}

extension OnChainValidator on String {
  bool isValidOnchainAddress() {
    return BITCOIN_PATTERN.hasMatch(replaceAll('bitcoin:', '').split('?')[0]);
  }
}

extension LnUrlValidator on String {
  bool isValidLnUrlAddress() {
    if (contains('://') && ('https://${split('://').last}').isValidUrl()) {
      return true;
    }
    try {
      const Bech32Codec().decode(
        this,
        length,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

extension Bolt11Validator on String {
  bool isValidBolt11Address() {
    try {
      const Bech32Codec().decode(
        this,
        length,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

bool isValidAddress(String addr) {
  return addr.isValidOnchainAddress() ||
      addr.isValidLnUrlAddress() ||
      addr.isValidBolt11Address() ||
      addr.isValidEmail();
}

Map<String, dynamic>? isValidAddressValidator(AbstractControl control) {
  return isValidAddress(control.value)
      ? null
      : <String, dynamic>{
          'Must be a valid lightning, onchain or lnurl address': control.value
        };
}

Map<String, dynamic>? isValidLightningAddressValidator(
    AbstractControl control) {
  return (control.value as String).isValidEmail()
      ? null
      : <String, dynamic>{'Must be a valid lightning address': control.value};
}
