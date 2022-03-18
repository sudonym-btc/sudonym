// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i5;
import 'data/dio/dio.client.dart' as _i25;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/pay.repository.dart' as _i8;
import 'data/mock/repository/pot.repository.dart' as _i18;
import 'data/mock/repository/receive.repository.dart' as _i10;
import 'data/mock/repository/transaction.repository.dart' as _i21;
import 'data/mock/repository/user.repository.dart' as _i16;
import 'data/mock/repository/websocket.dart' as _i14;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/pay.repository.dart' as _i7;
import 'data/repository/pot.repository.dart' as _i17;
import 'data/repository/receive.repository.dart' as _i9;
import 'data/repository/transaction.repository.dart' as _i20;
import 'data/repository/user.repository.dart' as _i23;
import 'data/repository/websocket.dart' as _i13;
import 'logic/bloc/auth.cubit.dart' as _i15;
import 'logic/bloc/pot.cubit.dart' as _i24;
import 'logic/bloc/receive.cubit.dart' as _i19;
import 'logic/bloc/send.cubit.dart' as _i11;
import 'logic/bloc/transactions.cubit.dart' as _i22;
import 'logic/bloc/user.cubit.dart' as _i12;

const String _dev = 'dev';
const String _staging = 'staging';
const String _prod = 'prod';
const String _mock = 'mock';
// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.factory<_i3.AuthRepository>(() => _i3.AuthRepositoryImpl(),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i3.AuthRepository>(() => _i4.MockAuthRepository(),
      registerFor: {_mock});
  gh.factory<_i5.Config>(() => _i5.MockConfig(), registerFor: {_mock});
  gh.factory<_i5.Config>(() => _i5.DevConfig(), registerFor: {_dev});
  gh.factory<_i5.Config>(() => _i5.ProdConfig(), registerFor: {_prod});
  gh.lazySingleton<_i6.Dio>(() => registerModule.dio(get<_i5.Config>()));
  gh.factory<_i7.PayRepository>(() => _i7.PayRepositoryImpl(get<_i6.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i7.PayRepository>(() => _i8.MockPayRepository(get<_i6.Dio>()),
      registerFor: {_mock});
  gh.factory<_i9.ReceiveRepository>(
      () => _i9.ReceiveRepositoryImpl(get<_i6.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i9.ReceiveRepository>(
      () => _i10.MockReceiveRepository(get<_i6.Dio>()),
      registerFor: {_mock});
  gh.factory<_i11.SendCubit>(() => _i11.SendCubit(get<_i7.PayRepository>()));
  gh.factory<_i12.UserCubit>(() => _i12.UserCubit());
  gh.factory<_i13.Websocket>(() => _i13.WebsocketImpl(),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i13.Websocket>(() => _i14.MockWebsocket(), registerFor: {_mock});
  gh.factory<_i15.AuthCubit>(() => _i15.AuthCubit(get<_i3.AuthRepository>()));
  gh.factory<_i16.MockUserRepository>(
      () => _i16.MockUserRepository(get<_i6.Dio>(), get<_i13.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i17.PotRepository>(
      () => _i17.PotRepositoryImpl(get<_i6.Dio>(), get<_i13.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i17.PotRepository>(
      () => _i18.MockPotRepository(get<_i6.Dio>(), get<_i13.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i19.ReceiveCubit>(
      () => _i19.ReceiveCubit(get<_i9.ReceiveRepository>()));
  gh.factory<_i20.TransactionRepository>(
      () =>
          _i20.TransactionRepositoryImpl(get<_i6.Dio>(), get<_i13.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i20.TransactionRepository>(
      () =>
          _i21.MockTransactionRepository(get<_i6.Dio>(), get<_i13.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i22.TransactionsCubit>(
      () => _i22.TransactionsCubit(get<_i20.TransactionRepository>()));
  gh.factory<_i23.UserRepository>(
      () => _i23.UserRepositoryImpl(get<_i6.Dio>(), get<_i13.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i24.PotCubit>(() => _i24.PotCubit(get<_i17.PotRepository>()));
  return get;
}

class _$RegisterModule extends _i25.RegisterModule {}
