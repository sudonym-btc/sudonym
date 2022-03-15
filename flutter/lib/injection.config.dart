// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'data/dio/dio.client.dart' as _i24;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/pay.repository.dart' as _i12;
import 'data/mock/repository/pot.repository.dart' as _i14;
import 'data/mock/repository/receive.repository.dart' as _i16;
import 'data/mock/repository/transaction.repository.dart' as _i19;
import 'data/mock/repository/user.repository.dart' as _i10;
import 'data/mock/repository/websocket.dart' as _i7;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/pay.repository.dart' as _i11;
import 'data/repository/pot.repository.dart' as _i13;
import 'data/repository/receive.repository.dart' as _i15;
import 'data/repository/transaction.repository.dart' as _i18;
import 'data/repository/user.repository.dart' as _i21;
import 'data/repository/websocket.dart' as _i6;
import 'logic/bloc/auth.cubit.dart' as _i8;
import 'logic/bloc/pot.cubit.dart' as _i22;
import 'logic/bloc/receive.cubit.dart' as _i23;
import 'logic/bloc/send.cubit.dart' as _i17;
import 'logic/bloc/transactions.cubit.dart' as _i20;
import 'logic/bloc/user.cubit.dart' as _i5;

const String _prod = 'prod';
const String _dev = 'dev';
// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.factory<_i3.AuthRepository>(() => _i3.AuthRepositoryImpl(),
      registerFor: {_prod});
  gh.factory<_i3.AuthRepository>(() => _i4.MockAuthRepository(),
      registerFor: {_dev});
  gh.factory<String>(() => registerModule.baseUrl, instanceName: 'BaseUrl');
  gh.factory<_i5.UserCubit>(() => _i5.UserCubit());
  gh.factory<_i6.Websocket>(() => _i6.WebsocketImpl(), registerFor: {_prod});
  gh.factory<_i6.Websocket>(() => _i7.MockWebsocket(), registerFor: {_dev});
  gh.factory<_i8.AuthCubit>(() => _i8.AuthCubit(get<_i3.AuthRepository>()));
  gh.lazySingleton<_i9.Dio>(
      () => registerModule.dio(get<String>(instanceName: 'BaseUrl')));
  gh.factory<_i10.MockUserRepository>(
      () => _i10.MockUserRepository(get<_i9.Dio>()),
      registerFor: {_dev});
  gh.factory<_i11.PayRepository>(() => _i11.PayRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_prod});
  gh.factory<_i11.PayRepository>(() => _i12.MockPayRepository(get<_i9.Dio>()),
      registerFor: {_dev});
  gh.factory<_i13.PotRepository>(() => _i13.PotRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_prod});
  gh.factory<_i13.PotRepository>(() => _i14.MockPotRepository(get<_i9.Dio>()),
      registerFor: {_dev});
  gh.factory<_i15.ReceiveRepository>(
      () => _i15.ReceiveRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_prod});
  gh.factory<_i15.ReceiveRepository>(
      () => _i16.MockReceiveRepository(get<_i9.Dio>()),
      registerFor: {_dev});
  gh.factory<_i17.SendCubit>(() => _i17.SendCubit(get<_i11.PayRepository>()));
  gh.factory<_i18.TransactionRepository>(
      () => _i18.TransactionRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_prod});
  gh.factory<_i18.TransactionRepository>(
      () => _i19.MockTransactionRepository(get<_i9.Dio>()),
      registerFor: {_dev});
  gh.factory<_i20.TransactionsCubit>(
      () => _i20.TransactionsCubit(get<_i18.TransactionRepository>()));
  gh.factory<_i21.UserRepository>(() => _i21.UserRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_prod});
  gh.factory<_i22.PotCubit>(() => _i22.PotCubit(get<_i13.PotRepository>()));
  gh.factory<_i23.ReceiveCubit>(
      () => _i23.ReceiveCubit(get<_i15.ReceiveRepository>()));
  return get;
}

class _$RegisterModule extends _i24.RegisterModule {}
