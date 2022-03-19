// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i6;
import 'data/dio/dio.client.dart' as _i27;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/pay.repository.dart' as _i9;
import 'data/mock/repository/pot.repository.dart' as _i20;
import 'data/mock/repository/receive.repository.dart' as _i11;
import 'data/mock/repository/transaction.repository.dart' as _i23;
import 'data/mock/repository/user.repository.dart' as _i18;
import 'data/mock/repository/websocket.dart' as _i16;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/pay.repository.dart' as _i8;
import 'data/repository/pot.repository.dart' as _i19;
import 'data/repository/receive.repository.dart' as _i10;
import 'data/repository/transaction.repository.dart' as _i22;
import 'data/repository/user.repository.dart' as _i25;
import 'data/repository/websocket.dart' as _i15;
import 'logic/bloc/auth.cubit.dart' as _i17;
import 'logic/bloc/pot.cubit.dart' as _i26;
import 'logic/bloc/receive.cubit.dart' as _i21;
import 'logic/bloc/send.cubit.dart' as _i12;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i5;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i13;
import 'logic/bloc/transactions.cubit.dart' as _i24;
import 'logic/bloc/user.cubit.dart' as _i14;

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
  gh.factory<_i5.ClipboardListener>(() => _i5.ClipboardListener());
  gh.factory<_i6.Config>(() => _i6.MockConfig(), registerFor: {_mock});
  gh.factory<_i6.Config>(() => _i6.DevConfig(), registerFor: {_dev});
  gh.factory<_i6.Config>(() => _i6.ProdConfig(), registerFor: {_prod});
  gh.lazySingleton<_i7.Dio>(() => registerModule.dio(get<_i6.Config>()));
  gh.factory<_i8.PayRepository>(() => _i8.PayRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i8.PayRepository>(() => _i9.MockPayRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i10.ReceiveRepository>(
      () => _i10.ReceiveRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i10.ReceiveRepository>(
      () => _i11.MockReceiveRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i12.SendCubit>(() => _i12.SendCubit(get<_i8.PayRepository>()));
  gh.factory<_i13.TransactionListenerCubit>(
      () => _i13.TransactionListenerCubit());
  gh.factory<_i14.UserCubit>(() => _i14.UserCubit());
  gh.factory<_i15.Websocket>(() => _i15.WebsocketImpl(),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i15.Websocket>(() => _i16.MockWebsocket(), registerFor: {_mock});
  gh.factory<_i17.AuthCubit>(() => _i17.AuthCubit(get<_i3.AuthRepository>()));
  gh.factory<_i18.MockUserRepository>(
      () => _i18.MockUserRepository(get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i19.PotRepository>(
      () => _i19.PotRepositoryImpl(get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i19.PotRepository>(
      () => _i20.MockPotRepository(get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i21.ReceiveCubit>(
      () => _i21.ReceiveCubit(get<_i10.ReceiveRepository>()));
  gh.factory<_i22.TransactionRepository>(
      () =>
          _i22.TransactionRepositoryImpl(get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i22.TransactionRepository>(
      () =>
          _i23.MockTransactionRepository(get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i24.TransactionsCubit>(
      () => _i24.TransactionsCubit(get<_i22.TransactionRepository>()));
  gh.factory<_i25.UserRepository>(
      () => _i25.UserRepositoryImpl(get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i26.PotCubit>(() => _i26.PotCubit(get<_i19.PotRepository>()));
  return get;
}

class _$RegisterModule extends _i27.RegisterModule {}
