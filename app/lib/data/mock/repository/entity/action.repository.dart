import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/types/currency.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
// import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically

@LazySingleton(as: ActionRepository, env: [Env.mock])
class MockActionRepository implements ActionRepository {
  final ReceiverRepository _receiveRepository;
  final TransactionRepository _transactionRepository;

  MockActionRepository(
      this._receiveRepository, this._transactionRepository, this.dio);

  @override
  Future<ActionParseResponse> parse(String address) async {
    await Future.delayed(requestDelay);
    return ActionParseResponse.from((await parseHelper(address)).toJson());
  }

  Future<dynamic> parseHelper(String address) async {
    var x = getType(address);
    String type = x[0];
    String trimmedAddress = x[1];

    switch (type) {
      case 'lightningaddress':
        return Action.from({
          'type': 'pay',
          'originalAddress': trimmedAddress,
          'isLnUrl': true,
          'isLightningAddress': true,
          'remoteResponse': await fetchRemoteLightningAddress(trimmedAddress)
        });
      case 'lnurl':
        var response = await fetchRemoteLnUrl(trimmedAddress);
        print(response);
        return Action.from({
          'type': response['data']['tag'].replaceAll('Request', ''),
          'originalAddress': trimmedAddress,
          'isLnUrl': true,
          'remoteResponse': response
        });
      default:
        return Action.from({
          'type': 'pay',
          'originalAddress': trimmedAddress,
          'isBolt11': true,
          'remoteResponse': await fetchBolt11(trimmedAddress)
        });
    }
  }

  validateInternetIdentifier(internetIdentifier) {
    var re = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    // print(re.hasMatch(internetIdentifier));
    return re.hasMatch(internetIdentifier);
  }

  @override
  getPaymentInfo(Payment action) async {
    await Future.delayed(requestDelay);
    return Payment.fromJson({
      ...action.toJson(),
      'address': 'lnbc123423432',
      'fee': 1000 / MSATOSHIS,
      'feeCurrency': 'BTC'
    });
  }

  @override
  getWithdrawInfo(Withdraw action) async {
    return Withdraw.fromJson({
      ...action.toJson(),
      'address': 'lnbc123423432',
      'fee': 1000 / MSATOSHIS,
      'feeCurrency': 'BTC'
    });
  }

  @override
  pay(Payment p) async {
    await Future.delayed(requestDelay);
    return _transactionRepository.create({
      'id': 1,
      'txid': null,
      'potId': p.potId ?? 1,
      'outgoing': true,
      'type': 'lnurl',
      'address': p.originalAddress,
      'originalAddress': p.originalAddress,
      'description': '',
      'amount': p.amount ?? 100,
      'status': null,
      'currencyCode': 'BTC',
      'createdAt': DateTime.now().toString()
    });
  }

  @override
  withdraw(Withdraw p) async {
    await Future.delayed(requestDelay);
    return _receiveRepository.create({
      'potId': p.potId ?? 1,
      'type': 'bolt11',
      'data': 'lnbct1',
      'amount': p.amount ?? 100,
      'amountCurrency': 'BTC',
      'received': 0,
      'createdAt': DateTime.now().toString()
    });
  }

  @override
  Dio dio;

  fetchBolt11(String invoice) async {
    return ActionRemoteResponse.fromJson({
      'success': true,
      'data': {
        'currency': 'bc',
        'created_at': 1656710563,
        'expiry': 86400,
        'msatoshi': 123456,
        'payee':
            '02925b6970e2dd07bcd45d9056040202fd371ceb34421472d8219e9742d70e26b6',
        'description': '',
        'min_final_cltv_expiry': 72,
        'payment_secret':
            '73009d5f51d4136f741ae873107a3e0f66cb3abbf2edd79efa8675319d33da18',
        'features': '008200',
        'routes': [],
        'payment_hash':
            '8c33e30066e1b446507c2fb0cda756b1287047495267158d303781e1141ef3c0',
        'signature':
            '3045022100f3c4957ba6d34509f298d73c400268268c8e21a1e2dc345285e61051e7ea463702203f936c66e005f4ff568caf2033200b461e3abdc8080ae24bccd8bb1ee239f548'
      }
    }).toJson();
  }

  fetchRemoteLightningAddress(String internetIdentifier) async {
    return ActionRemoteResponse.fromJson({
      'success': true,
      'data': {
        'status': 'OK',
        'callback':
            'https://coincorner.io/lnurl/payreq/2b8113a7-63e8-4bcd-ab9d-2908b1379652',
        'maxSendable': 100000000,
        'minSendable': 1000,
        'metadata': '[["text/plain", "paco@coincorner.io"]]',
        'commentAllowed': 0,
        'tag': 'payRequest',
        'domain': 'coincorner.io',
        'username': 'paco'
      }
    }).toJson();
  }

  fetchRemoteLnUrl(String invoice) {
    if (invoice.contains("lnurlw")) {
      return ActionRemoteResponse.fromJson({
        'success': true,
        'data': {
          'status': 'OK',
          'callback': 'https://coincorner.io/lnurlw/',
          'maxWithdrawable': 100000000,
          'minWithdrawable': 1000,
          'metadata': '[["text/plain", "paco@coincorner.io"]]',
          'commentAllowed': 0,
          'tag': 'withdrawRequest',
          'domain': 'coincorner.io',
          'username': 'paco'
        }
      }).toJson();
    }
    return fetchRemoteLightningAddress(invoice);
  }

  getType(String address) {
    address = address.trim().toLowerCase();
    if (address == '') {
      return null;
    }

    // Check if this is a Lightning Address
    if (validateInternetIdentifier(address)) {
      return ['lightningaddress', address];
    }
    // Check if Invoice has `lightning` or `lnurl` prefixes
    // (9 chars + the `:` or `=` chars) --> 10 characters total
    bool hasLightningPrefix = address.contains('$LIGHTNING_SCHEME:');
    if (hasLightningPrefix) {
      // Remove the `lightning` prefix
      address = address.substring(10, address.length);
    }

    // (5 chars + the `:` or `=` chars) --> 6 characters total
    bool hasLNURLPrefix = address.contains('$LNURL_SCHEME:');
    if (hasLNURLPrefix) {
      // Remove the `lightning` prefix
      address = address.substring(6, address.length);
    }

    // Parse LNURL or BOLT11
    var isLnUrl = address.startsWith(LNURL_SCHEME);

    return [isLnUrl ? 'lnurl' : 'bolt11', address];
  }
}
