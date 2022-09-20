// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i7;
import 'data/dio/dio.client.dart' as _i42;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/currency.repository.dart' as _i33;
import 'data/mock/repository/entity/action.repository.dart' as _i27;
import 'data/mock/repository/entity/bolt_card.repository.dart' as _i28;
import 'data/mock/repository/entity/contact.repository.dart' as _i31;
import 'data/mock/repository/entity/pot.repository.dart' as _i15;
import 'data/mock/repository/entity/receiver.repository.dart' as _i17;
import 'data/mock/repository/entity/transaction.repository.dart' as _i20;
import 'data/mock/repository/entity/user-device.repository.dart' as _i22;
import 'data/mock/repository/entity/user.repository.dart' as _i23;
import 'data/mock/repository/websocket.dart' as _i25;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/currency.repository.dart' as _i32;
import 'data/repository/entity/action.repository.dart' as _i26;
import 'data/repository/entity/bolt_card.repository.dart' as _i29;
import 'data/repository/entity/contact.repository.dart' as _i30;
import 'data/repository/entity/pot.repository.dart' as _i35;
import 'data/repository/entity/receiver.repository.dart' as _i36;
import 'data/repository/entity/transaction.repository.dart' as _i38;
import 'data/repository/entity/user-device.repository.dart' as _i39;
import 'data/repository/entity/user.repository.dart' as _i40;
import 'data/repository/index.dart' as _i14;
import 'data/repository/websocket.dart' as _i24;
import 'logic/bloc/auth.cubit.dart' as _i41;
import 'logic/bloc/entity/bolt_card.cubit.dart' as _i5;
import 'logic/bloc/entity/contact.cubit.dart' as _i8;
import 'logic/bloc/entity/pot.cubit.dart' as _i13;
import 'logic/bloc/entity/receiver.cubit.dart' as _i16;
import 'logic/bloc/entity/transaction.cubit.dart' as _i18;
import 'logic/bloc/entity/user.cubit.dart' as _i21;
import 'logic/bloc/link.service.dart' as _i34;
import 'logic/bloc/pages/send.cubit.dart' as _i37;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i6;
import 'logic/bloc/transaction-listener/link-listener.dart' as _i10;
import 'logic/bloc/transaction-listener/nfc-listener.dart' as _i12;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i19;
import 'logic/nfc.cubit.dart' as _i11;

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
  gh.factory<_i5.BoltCardCubit>(() => _i5.BoltCardCubit());
  gh.factory<_i6.ClipboardListener>(() => _i6.ClipboardListener());
  gh.factory<_i7.Config>(() => _i7.DevConfig(), registerFor: {_dev});
  gh.factory<_i7.Config>(() => _i7.TestConfig(), registerFor: {_test});
  gh.factory<_i7.Config>(() => _i7.StagingConfig(), registerFor: {_staging});
  gh.factory<_i7.Config>(() => _i7.ProdConfig(), registerFor: {_prod});
  gh.factory<_i7.Config>(() => _i7.MockConfig(), registerFor: {_mock});
  gh.factory<_i8.ContactCubit>(() => _i8.ContactCubit());
  gh.lazySingleton<_i9.Dio>(() => registerModule.dio(get<_i7.Config>()));
  gh.factory<_i10.LinkListener>(() => _i10.LinkListener());
  gh.factory<_i11.NFCCubit>(() => _i11.NFCCubit());
  gh.factory<_i12.NFCListener>(() => _i12.NFCListener());
  gh.factory<_i13.PotCubit>(() => _i13.PotCubit());
  gh.lazySingleton<_i14.PotRepository>(
      () => _i15.MockPotRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i16.ReceiverCubit>(() => _i16.ReceiverCubit());
  gh.lazySingleton<_i14.ReceiverRepository>(
      () => _i17.MockReceiveRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i18.TransactionCubit>(() => _i18.TransactionCubit());
  gh.factory<_i19.TransactionListenerCubit>(
      () => _i19.TransactionListenerCubit());
  gh.lazySingleton<_i14.TransactionRepository>(
      () => _i20.MockTransactionRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i21.UserCubit>(() => _i21.UserCubit());
  gh.lazySingleton<_i14.UserDeviceRepository>(
      () => _i22.MockUserDeviceRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i14.UserRepository>(
      () => _i23.MockUserRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.singleton<_i24.Websocket>(_i24.WebsocketImpl(get<_i7.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i24.Websocket>(_i25.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i26.ActionRepository>(
      () => _i26.ActionRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i14.ActionRepository>(
      () => _i27.MockActionRepository(get<_i14.ReceiverRepository>(),
          get<_i14.TransactionRepository>(), get<_i9.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i14.BoltCardRepository>(
      () => _i28.MockBoltCardRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i29.BoltCardRepository>(
      () => _i29.BoltCardRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i30.ContactRepository>(
      () => _i30.ContactRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i14.ContactRepository>(
      () => _i31.MockContactRepository(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i14.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i32.CurrencyRepository>(
      () => _i33.MockCurrencyRepository(get<_i9.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i32.CurrencyRepository>(
      () => _i32.CurrencyRepositoryImpl(get<_i9.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i34.LinkService>(
      () => _i34.LinkService(get<_i26.ActionRepository>()));
  gh.lazySingleton<_i35.PotRepository>(
      () => _i35.PotRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i36.ReceiverRepository>(
      () => _i36.ReceiverRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i37.SendCubit>(
      () => _i37.SendCubit(get<_i26.ActionRepository>()));
  gh.lazySingleton<_i38.TransactionRepository>(
      () => _i38.TransactionRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i39.UserDeviceRepository>(
      () => _i39.UserDeviceRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i40.UserRepository>(
      () => _i40.UserRepositoryImpl(
          get<_i7.Config>(), get<_i9.Dio>(), get<_i24.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i41.AuthCubit>(_i41.AuthCubit(get<_i3.AuthRepository>(),
      get<_i40.UserRepository>(), get<_i24.Websocket>()));
  return get;
}

class _$RegisterModule extends _i42.RegisterModule {}
