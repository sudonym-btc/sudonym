import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/mock/repository/crud_repository.dart';
import 'package:sudonym/data/repository/receive.repository.dart';
import 'package:sudonym/injection.dart';

@LazySingleton(as: ReceiveRepository, env: [Env.mock])
class MockReceiveRepository implements ReceiveRepository {
  @override
  List<Receiver> receivers = [];
  MockReceiveRepository(this.dio);

  @override
  getInvoice(potId, type, amount, currency) async {
    await Future.delayed(requestDelay);
    var data;
    if (type == "bolt12") {
      data =
          "lno1pg257enxv4ezqcneype82um50ynhxgrwdajx283qfwdpl28qqmc78ymlvhmxcsywdk5wrjnj36jryg488qwlrnzyjczs";
    } else if (type == "bolt11") {
      data =
          "lnbc639500n1p3zhu4zpp5ppdrp82y8pf59dhlsvy9959h48z9n8alr43yfxpdp8sepjggks6sdqqcqzpuxqyz5vqsp5c8spnur4r52z0uc9lshtswapnyfjnefpjw42atv4fxvljxnnq4mq9qyyssqq7hg5u8jyk02jlevd0jvz9945day8n36aq8kljgq4jhs6dv2s2z4wn3kzhjmkwsj6x4d3hh4qfccvfw8kn64e3fffjuc0tqwuaufcjcqkv9anx";
    } else if (type == "lnurl") {
      data =
          "LNURL1DP68GURN8GHJ7AMPD3KX2AR0VEEKZAR0WD5XJTNRDAKJ7TNHV4KXCTTTDEHHWM30D3H82UNVWQHHWMM00FUHXAR0WFJNYWQETNXTY";
    } else if (type == "onchain") {
      data = "bc1qw69mpwfcmcg4segjdm9qmrwfn0n230tcve8wg6h7fa8r996zm7pqfuk0me";
    }
    Receiver r = Receiver({
      "id": 1,
      "potId": 1,
      "type": type,
      "amount": amount,
      "currency": currency,
      "data": data,
      "createdAt": DateTime.now()
    });
    receivers.add(r);
    print(receivers);
    return r;
  }

  @override
  Dio dio;
}
