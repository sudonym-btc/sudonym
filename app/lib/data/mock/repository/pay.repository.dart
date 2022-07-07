import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/address-parse-response.dart';
import 'package:sudonym.models/payment.dart';
import 'package:sudonym.models/receiver.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/data/helper/address-parser.dart';
import 'package:sudonym/data/repository/receive.repository.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/data/mock/repository/crud_repository.dart';
import 'package:sudonym/data/repository/pay.repository.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically

@LazySingleton(as: PayRepository, env: [Env.mock])
class MockPayRepository implements PayRepository {
  ReceiveRepository _receiveRepository;
  TransactionRepository _transactionRepository;

  MockPayRepository(
      this._receiveRepository, this._transactionRepository, this.dio);

  @override
  parse(String addr) async {
    await Future.delayed(requestDelay);

    if (addr == "") return null;
    addr = addr.trim().toLowerCase().split(':').last;
    if (validateInternetIdentifier(addr)) {
      return await handleLightningAddress(addr);
    }

    // Check if Invoice has `lightning` or `lnurl` prefixes
    // (9 chars + the `:` or `=` chars) --> 10 characters total
    bool hasLightningPrefix = addr.contains(LIGHTNING_SCHEME + ':');
    if (hasLightningPrefix) {
      // Remove the `lightning` prefix
      addr = addr.substring(10, addr.length);
    }

    // (5 chars + the `:` or `=` chars) --> 6 characters total
    bool hasLNURLPrefix = addr.contains(LNURL_SCHEME + ':');
    if (hasLNURLPrefix) {
      // Remove the `lightning` prefix
      addr = addr.substring(6, addr.length);
    }

    // Parse LNURL or BOLT11
    bool isLnUrl = addr.startsWith(LNURL_SCHEME);
    if (isLnUrl) {
      return await handleLnUrl(addr);
    } else {
      return handleBolt11(addr);
    }
  }

  handleLnUrl(String addr) {
    AddressParseResponse a = AddressParseResponse({
      "originalInput": addr,
      "success": true,
      "data": {
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
    });
    a.set("isLnUrl", true);
    a.set("isLnAddress", true);
    return a;
  }

  handleBolt11(String addr) {
    Receiver? r = _receiveRepository.receivers
        .firstWhereOrNull((element) => element.get("data") == addr);

    AddressParseResponse a = AddressParseResponse({
      "originalInput": addr,
      "success": true,
      "data": {
        'currency': 'bc',
        'created_at': 1656710563,
        'expiry': 86400,
        'msatoshi': r?.get("amount"),
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
    });
    a.set("isBolt11", true);
    return a;
  }

  handleLightningAddress(String addr) {
    AddressParseResponse a = AddressParseResponse({
      "success": true,
      "originalInput": addr,
      "data": {
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
    });
    a.set("isLnUrl", true);
    a.set("isLnAddress", true);
    return a;
  }

  validateInternetIdentifier(internetIdentifier) {
    var re = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    print(re.hasMatch(internetIdentifier));
    return re.hasMatch(internetIdentifier);
  }

  @override
  getInfo(Payment p) async {
    await Future.delayed(requestDelay);
    return Payment({
      "originalAddress": p.get("originalAddress"),
      "address": p.get("address"),
      "amount": p.get("amount"),
      "maxAmount": p.get("amount"),
      "minAmount": p.get("amount"),
      "fee": 1000
    });
  }

  @override
  pay(Payment p) async {
    await Future.delayed(requestDelay);
    return _transactionRepository.create(Transaction({
      "id": 1,
      "txid": null,
      "potId": p.get("potId"),
      "outgoing": true,
      "type": "lnurl",
      "address": p.get("originalAddress"),
      "originalAddress": p.get("originalAddress"),
      "description": "",
      "amount": p.get("amount") ?? 100,
      "status": null,
      "currencyCode": "BTC",
      "createdAt": DateTime.now()
    }));
  }

  @override
  Dio dio;
}
