// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i6;
import 'data/dio/dio.client.dart' as _i42;
import 'data/mock/repository/action.repository.dart' as _i35;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/bolt_card.repository.dart' as _i18;
import 'data/mock/repository/contact.repository.dart' as _i20;
import 'data/mock/repository/currency.repository.dart' as _i22;
import 'data/mock/repository/pot.repository.dart' as _i25;
import 'data/mock/repository/receive.repository.dart' as _i12;
import 'data/mock/repository/transaction.repository.dart' as _i29;
import 'data/mock/repository/user-device.repository.dart' as _i32;
import 'data/mock/repository/user.repository.dart' as _i34;
import 'data/mock/repository/websocket.dart' as _i15;
import 'data/repository/action.repository.dart' as _i16;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/bolt_card.repository.dart' as _i17;
import 'data/repository/contact.repository.dart' as _i19;
import 'data/repository/currency.repository.dart' as _i21;
import 'data/repository/pot.repository.dart' as _i24;
import 'data/repository/receive.repository.dart' as _i11;
import 'data/repository/transaction.repository.dart' as _i28;
import 'data/repository/user-device.repository.dart' as _i31;
import 'data/repository/user.repository.dart' as _i33;
import 'data/repository/websocket.dart' as _i14;
import 'logic/bloc/auth.cubit.dart' as _i36;
import 'logic/bloc/bolt_card.cubit.dart' as _i37;
import 'logic/bloc/contact.cubit.dart' as _i38;
import 'logic/bloc/link.service.dart' as _i23;
import 'logic/bloc/pages/home/pot_slider.cubit.dart' as _i10;
import 'logic/bloc/pot.cubit.dart' as _i39;
import 'logic/bloc/receive.cubit.dart' as _i26;
import 'logic/bloc/send.cubit.dart' as _i27;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i5;
import 'logic/bloc/transaction-listener/link-listener.dart' as _i8;
import 'logic/bloc/transaction-listener/nfc-listener.dart' as _i9;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i13;
import 'logic/bloc/transaction.cubit.dart' as _i40;
import 'logic/bloc/transactions.cubit.dart' as _i30;
import 'logic/bloc/user.cubit.dart' as _i41;

const String _dev = 'dev';
const String _test = 'test';
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
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i3.AuthRepository>(() => _i4.MockAuthRepository(),
      registerFor: {_mock});
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
      () => _i12.MockReceiveRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i11.ReceiveRepository>(
      () => _i11.ReceiveRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i13.TransactionListenerCubit>(
      () => _i13.TransactionListenerCubit());
  gh.singleton<_i14.Websocket>(_i14.WebsocketImpl(get<_i6.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i14.Websocket>(_i15.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i16.ActionRepository>(
      () => _i16.ActionRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i17.BoltCardRepository>(
      () => _i18.MockBoltCardRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i17.BoltCardRepository>(
      () => _i17.BoltCardRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i19.ContactRepository>(
      () => _i20.MockContactRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i19.ContactRepository>(
      () => _i19.ContactRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i21.CurrencyRepository>(
      () => _i22.MockCurrencyRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i21.CurrencyRepository>(
      () => _i21.CurrencyRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i23.LinkService>(
      () => _i23.LinkService(get<_i16.ActionRepository>()));
  gh.lazySingleton<_i24.PotRepository>(
      () => _i25.MockPotRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i24.PotRepository>(
      () => _i24.PotRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i26.ReceiveCubit>(
      () => _i26.ReceiveCubit(get<_i11.ReceiveRepository>()));
  gh.factory<_i27.SendCubit>(
      () => _i27.SendCubit(get<_i16.ActionRepository>()));
  gh.lazySingleton<_i28.TransactionRepository>(
      () => _i28.TransactionRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i28.TransactionRepository>(
      () => _i29.MockTransactionRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i30.TransactionsCubit>(
      () => _i30.TransactionsCubit(get<_i28.TransactionRepository>()));
  gh.lazySingleton<_i31.UserDeviceRepository>(
      () => _i32.MockUserDeviceRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i31.UserDeviceRepository>(
      () => _i31.UserDeviceRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i33.UserRepository>(
      () => _i33.UserRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i33.UserRepository>(
      () => _i34.MockUserRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i16.ActionRepository>(
      () => _i35.MockActionRepository(get<_i11.ReceiveRepository>(),
          get<_i28.TransactionRepository>(), get<_i7.Dio>()),
      registerFor: {_mock});
  gh.singleton<_i36.AuthCubit>(_i36.AuthCubit(get<_i3.AuthRepository>(),
      get<_i33.UserRepository>(), get<_i14.Websocket>()));
  gh.factory<_i37.BoltCardCubit>(
      () => _i37.BoltCardCubit(get<_i17.BoltCardRepository>()));
  gh.factory<_i38.ContactCubit>(
      () => _i38.ContactCubit(get<_i19.ContactRepository>()));
  gh.factory<_i39.PotCubit>(() => _i39.PotCubit(get<_i24.PotRepository>()));
  gh.factory<_i40.TransactionCubit>(
      () => _i40.TransactionCubit(get<_i28.TransactionRepository>()));
  gh.factory<_i41.UserCubit>(() => _i41.UserCubit(get<_i33.UserRepository>()));
  return get;
}

class _$RegisterModule extends _i42.RegisterModule {}
