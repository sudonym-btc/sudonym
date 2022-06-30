// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i6;
import 'data/dio/dio.client.dart' as _i33;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/contact.repository.dart' as _i21;
import 'data/mock/repository/pay.repository.dart' as _i10;
import 'data/mock/repository/pot.repository.dart' as _i23;
import 'data/mock/repository/receive.repository.dart' as _i13;
import 'data/mock/repository/transaction.repository.dart' as _i26;
import 'data/mock/repository/user.repository.dart' as _i29;
import 'data/mock/repository/websocket.dart' as _i18;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/contact.repository.dart' as _i20;
import 'data/repository/pay.repository.dart' as _i9;
import 'data/repository/pot.repository.dart' as _i22;
import 'data/repository/receive.repository.dart' as _i12;
import 'data/repository/transaction.repository.dart' as _i25;
import 'data/repository/user.repository.dart' as _i28;
import 'data/repository/websocket.dart' as _i17;
import 'logic/bloc/auth.cubit.dart' as _i19;
import 'logic/bloc/contact.cubit.dart' as _i30;
import 'logic/bloc/link.service.dart' as _i8;
import 'logic/bloc/pages/home/pot_slider.cubit.dart' as _i11;
import 'logic/bloc/pot.cubit.dart' as _i31;
import 'logic/bloc/receive.cubit.dart' as _i24;
import 'logic/bloc/send.cubit.dart' as _i14;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i5;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i15;
import 'logic/bloc/transaction.cubit.dart' as _i32;
import 'logic/bloc/transactions.cubit.dart' as _i27;
import 'logic/bloc/user.cubit.dart' as _i16;

const String _mock = 'mock';
const String _dev = 'dev';
const String _staging = 'staging';
const String _prod = 'prod';
// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.factory<_i3.AuthRepository>(() => _i4.MockAuthRepository(),
      registerFor: {_mock});
  gh.factory<_i3.AuthRepository>(() => _i3.AuthRepositoryImpl(),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i5.ClipboardListener>(() => _i5.ClipboardListener());
  gh.factory<_i6.Config>(() => _i6.MockConfig(), registerFor: {_mock});
  gh.factory<_i6.Config>(() => _i6.DevConfig(), registerFor: {_dev});
  gh.factory<_i6.Config>(() => _i6.ProdConfig(), registerFor: {_prod});
  gh.lazySingleton<_i7.Dio>(() => registerModule.dio(get<_i6.Config>()));
  gh.lazySingleton<_i8.LinkService>(() => _i8.LinkService());
  gh.factory<_i9.PayRepository>(() => _i10.MockPayRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i9.PayRepository>(() => _i9.PayRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i11.PotSliderCubit>(() => _i11.PotSliderCubit(get<int>()));
  gh.factory<_i12.ReceiveRepository>(
      () => _i13.MockReceiveRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i12.ReceiveRepository>(
      () => _i12.ReceiveRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i14.SendCubit>(() => _i14.SendCubit(get<_i9.PayRepository>()));
  gh.factory<_i15.TransactionListenerCubit>(
      () => _i15.TransactionListenerCubit());
  gh.factory<_i16.UserCubit>(() => _i16.UserCubit());
  gh.singleton<_i17.Websocket>(_i18.MockWebsocket(), registerFor: {_mock});
  gh.singleton<_i17.Websocket>(_i17.WebsocketImpl(get<_i6.Config>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i19.AuthCubit>(
      () => _i19.AuthCubit(get<_i3.AuthRepository>(), get<_i17.Websocket>()));
  gh.factory<_i20.ContactRepository>(
      () => _i21.MockContactRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i20.ContactRepository>(
      () => _i20.ContactRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i22.PotRepository>(
      () => _i23.MockPotRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i22.PotRepository>(
      () => _i22.PotRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i24.ReceiveCubit>(
      () => _i24.ReceiveCubit(get<_i12.ReceiveRepository>()));
  gh.factory<_i25.TransactionRepository>(
      () => _i26.MockTransactionRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i25.TransactionRepository>(
      () => _i25.TransactionRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i27.TransactionsCubit>(
      () => _i27.TransactionsCubit(get<_i25.TransactionRepository>()));
  gh.factory<_i28.UserRepository>(
      () => _i29.MockUserRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i28.UserRepository>(
      () => _i28.UserRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i17.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i30.ContactCubit>(
      () => _i30.ContactCubit(get<_i20.ContactRepository>()));
  gh.factory<_i31.PotCubit>(() => _i31.PotCubit(get<_i22.PotRepository>()));
  gh.factory<_i32.TransactionCubit>(
      () => _i32.TransactionCubit(get<_i25.TransactionRepository>()));
  return get;
}

class _$RegisterModule extends _i33.RegisterModule {}
