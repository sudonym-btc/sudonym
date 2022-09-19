// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i6;
import 'data/dio/dio.client.dart' as _i39;
import 'data/mock/repository/action.repository.dart' as _i33;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/contact.repository.dart' as _i18;
import 'data/mock/repository/currency.repository.dart' as _i20;
import 'data/mock/repository/pot.repository.dart' as _i23;
import 'data/mock/repository/receive.repository.dart' as _i12;
import 'data/mock/repository/transaction.repository.dart' as _i27;
import 'data/mock/repository/user-device.repository.dart' as _i30;
import 'data/mock/repository/user.repository.dart' as _i32;
import 'data/mock/repository/websocket.dart' as _i15;
import 'data/repository/action.repository.dart' as _i16;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/contact.repository.dart' as _i17;
import 'data/repository/currency.repository.dart' as _i19;
import 'data/repository/pot.repository.dart' as _i22;
import 'data/repository/receive.repository.dart' as _i11;
import 'data/repository/transaction.repository.dart' as _i26;
import 'data/repository/user-device.repository.dart' as _i29;
import 'data/repository/user.repository.dart' as _i31;
import 'data/repository/websocket.dart' as _i14;
import 'logic/bloc/auth.cubit.dart' as _i34;
import 'logic/bloc/contact.cubit.dart' as _i35;
import 'logic/bloc/link.service.dart' as _i21;
import 'logic/bloc/pages/home/pot_slider.cubit.dart' as _i10;
import 'logic/bloc/pot.cubit.dart' as _i36;
import 'logic/bloc/receive.cubit.dart' as _i24;
import 'logic/bloc/send.cubit.dart' as _i25;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i5;
import 'logic/bloc/transaction-listener/link-listener.dart' as _i8;
import 'logic/bloc/transaction-listener/nfc-listener.dart' as _i9;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i13;
import 'logic/bloc/transaction.cubit.dart' as _i37;
import 'logic/bloc/transactions.cubit.dart' as _i28;
import 'logic/bloc/user.cubit.dart' as _i38;

const String _mock = 'mock';
const String _dev = 'dev';
const String _test = 'test';
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
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i5.ClipboardListener>(() => _i5.ClipboardListener());
  gh.factory<_i6.Config>(() => _i6.DevConfig(), registerFor: {_dev});
  gh.factory<_i6.Config>(() => _i6.TestConfig(), registerFor: {_test});
  gh.factory<_i6.Config>(() => _i6.StagingConfig(), registerFor: {_staging});
  gh.factory<_i6.Config>(() => _i6.ProdConfig(), registerFor: {_prod});
  gh.factory<_i6.Config>(() => _i6.MockConfig(), registerFor: {_mock});
  gh.lazySingleton<_i7.Dio>(() => registerModule.dio(get<_i6.Config>()));
  gh.factory<_i8.LinkListener>(() => _i8.LinkListener());
  gh.factory<_i9.NFCListener>(() => _i9.NFCListener());
  gh.factory<_i10.PotSliderCubit>(() => _i10.PotSliderCubit(get<int>()));
  gh.lazySingleton<_i11.ReceiveRepository>(
      () => _i11.ReceiveRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i11.ReceiveRepository>(
      () => _i12.MockReceiveRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i13.TransactionListenerCubit>(
      () => _i13.TransactionListenerCubit());
  gh.singleton<_i14.Websocket>(_i14.WebsocketImpl(get<_i6.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i14.Websocket>(_i15.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i16.ActionRepository>(
      () => _i16.ActionRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i17.ContactRepository>(
      () => _i18.MockContactRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i17.ContactRepository>(
      () => _i17.ContactRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i19.CurrencyRepository>(
      () => _i20.MockCurrencyRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i19.CurrencyRepository>(
      () => _i19.CurrencyRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i21.LinkService>(
      () => _i21.LinkService(get<_i16.ActionRepository>()));
  gh.lazySingleton<_i22.PotRepository>(
      () => _i22.PotRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i22.PotRepository>(
      () => _i23.MockPotRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i24.ReceiveCubit>(
      () => _i24.ReceiveCubit(get<_i11.ReceiveRepository>()));
  gh.factory<_i25.SendCubit>(
      () => _i25.SendCubit(get<_i16.ActionRepository>()));
  gh.lazySingleton<_i26.TransactionRepository>(
      () => _i27.MockTransactionRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i26.TransactionRepository>(
      () => _i26.TransactionRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i28.TransactionsCubit>(
      () => _i28.TransactionsCubit(get<_i26.TransactionRepository>()));
  gh.lazySingleton<_i29.UserDeviceRepository>(
      () => _i30.MockUserDeviceRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i29.UserDeviceRepository>(
      () => _i29.UserDeviceRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i31.UserRepository>(
      () => _i31.UserRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i31.UserRepository>(
      () => _i32.MockUserRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i16.ActionRepository>(
      () => _i33.MockActionRepository(get<_i11.ReceiveRepository>(),
          get<_i26.TransactionRepository>(), get<_i7.Dio>()),
      registerFor: {_mock});
  gh.singleton<_i34.AuthCubit>(_i34.AuthCubit(get<_i3.AuthRepository>(),
      get<_i31.UserRepository>(), get<_i14.Websocket>()));
  gh.factory<_i35.ContactCubit>(
      () => _i35.ContactCubit(get<_i17.ContactRepository>()));
  gh.factory<_i36.PotCubit>(() => _i36.PotCubit(get<_i22.PotRepository>()));
  gh.factory<_i37.TransactionCubit>(
      () => _i37.TransactionCubit(get<_i26.TransactionRepository>()));
  gh.factory<_i38.UserCubit>(() => _i38.UserCubit(get<_i31.UserRepository>()));
  return get;
}

class _$RegisterModule extends _i39.RegisterModule {}
