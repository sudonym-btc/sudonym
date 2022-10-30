// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i13;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i10;
import 'config/index.dart' as _i19;
import 'data/dio/dio.client.dart' as _i44;
import 'data/index.dart' as _i6;
import 'data/mock/repository/auth.repository.dart' as _i7;
import 'data/mock/repository/currency.repository.dart' as _i43;
import 'data/mock/repository/entity/action.repository.dart' as _i35;
import 'data/mock/repository/entity/bolt_card.repository.dart' as _i38;
import 'data/mock/repository/entity/contact.repository.dart' as _i41;
import 'data/mock/repository/entity/pot.repository.dart' as _i20;
import 'data/mock/repository/entity/receiver.repository.dart' as _i23;
import 'data/mock/repository/entity/transaction.repository.dart' as _i27;
import 'data/mock/repository/entity/user-device.repository.dart' as _i29;
import 'data/mock/repository/entity/user.repository.dart' as _i31;
import 'data/mock/repository/websocket.dart' as _i34;
import 'data/repository/auth.repository.dart' as _i5;
import 'data/repository/currency.repository.dart' as _i42;
import 'data/repository/entity/action.repository.dart' as _i36;
import 'data/repository/entity/bolt_card.repository.dart' as _i39;
import 'data/repository/entity/contact.repository.dart' as _i40;
import 'data/repository/entity/pot.repository.dart' as _i18;
import 'data/repository/entity/receiver.repository.dart' as _i22;
import 'data/repository/entity/transaction.repository.dart' as _i26;
import 'data/repository/entity/user-device.repository.dart' as _i30;
import 'data/repository/entity/user.repository.dart' as _i32;
import 'data/repository/websocket.dart' as _i33;
import 'logic/bloc/action.cubit.dart' as _i3;
import 'logic/bloc/action_trigger.service.dart' as _i4;
import 'logic/bloc/auth.cubit.dart' as _i37;
import 'logic/bloc/currency_input.cubit.dart' as _i12;
import 'logic/bloc/entity/bolt_card.cubit.dart' as _i8;
import 'logic/bloc/entity/contact.cubit.dart' as _i11;
import 'logic/bloc/entity/pot.cubit.dart' as _i17;
import 'logic/bloc/entity/receiver.cubit.dart' as _i21;
import 'logic/bloc/entity/transaction.cubit.dart' as _i24;
import 'logic/bloc/entity/user.cubit.dart' as _i28;
import 'logic/bloc/transaction-listener/clipboard_listener.dart' as _i9;
import 'logic/bloc/transaction-listener/link_listener.dart' as _i14;
import 'logic/bloc/transaction-listener/nfc_listener.dart' as _i16;
import 'logic/bloc/transaction-listener/transaction_listener.cubit.dart'
    as _i25;
import 'logic/nfc.cubit.dart' as _i15;

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
  gh.factory<_i3.ActionLoader>(() => _i3.ActionLoader(get<String>()));
  gh.lazySingleton<_i4.ActionTriggerService>(() => _i4.ActionTriggerService());
  gh.factory<_i5.AuthRepository>(() => _i5.AuthRepositoryImpl(),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i6.AuthRepository>(() => _i7.MockAuthRepository(),
      registerFor: {_mock});
  gh.factory<_i8.BoltCardCubit>(() => _i8.BoltCardCubit());
  gh.factory<_i9.ClipboardListener>(() => _i9.ClipboardListener());
  gh.factory<_i10.Config>(() => _i10.DevConfig(), registerFor: {_dev});
  gh.factory<_i10.Config>(() => _i10.TestConfig(), registerFor: {_test});
  gh.factory<_i10.Config>(() => _i10.StagingConfig(), registerFor: {_staging});
  gh.factory<_i10.Config>(() => _i10.MockConfig(), registerFor: {_mock});
  gh.factory<_i10.Config>(() => _i10.ProdConfig(), registerFor: {_prod});
  gh.factory<_i11.ContactCubit>(() => _i11.ContactCubit());
  gh.factory<_i12.CurrencyInputCubit>(
      () => _i12.CurrencyInputCubit(get<_i12.CurrencyInputOptions>()));
  gh.lazySingleton<_i13.Dio>(() => registerModule.dio(get<_i10.Config>()));
  gh.factory<_i14.LinkListener>(() => _i14.LinkListener());
  gh.factory<_i15.NFCCubit>(() => _i15.NFCCubit());
  gh.factory<_i16.NFCListener>(() => _i16.NFCListener());
  gh.factory<_i17.PotCubit>(() => _i17.PotCubit());
  gh.lazySingleton<_i18.PotRepository>(
      () => _i18.PotRepositoryImpl(
          get<_i19.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.PotRepository>(
      () => _i20.MockPotRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i21.ReceiverCubit>(() => _i21.ReceiverCubit());
  gh.lazySingleton<_i22.ReceiverRepository>(
      () => _i22.ReceiverRepositoryImpl(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.ReceiverRepository>(
      () => _i23.MockReceiveRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i24.TransactionCubit>(() => _i24.TransactionCubit());
  gh.factory<_i25.TransactionListenerCubit>(
      () => _i25.TransactionListenerCubit());
  gh.lazySingleton<_i26.TransactionRepository>(
      () => _i26.TransactionRepositoryImpl(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.TransactionRepository>(
      () => _i27.MockTransactionRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i28.UserCubit>(() => _i28.UserCubit());
  gh.lazySingleton<_i6.UserDeviceRepository>(
      () => _i29.MockUserDeviceRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i30.UserDeviceRepository>(
      () => _i30.UserDeviceRepositoryImpl(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.UserRepository>(
      () => _i31.MockUserRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i32.UserRepository>(
      () => _i32.UserRepositoryImpl(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i33.Websocket>(_i34.MockWebsocket(), registerFor: {_mock});
  gh.singleton<_i33.Websocket>(_i33.WebsocketImpl(get<_i10.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.ActionRepository>(
      () => _i35.MockActionRepository(get<_i6.ReceiverRepository>(),
          get<_i6.TransactionRepository>(), get<_i13.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i36.ActionRepository>(
      () => _i36.ActionRepositoryImpl(get<_i13.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i37.AuthCubit>(_i37.AuthCubit(get<_i6.AuthRepository>(),
      get<_i6.UserRepository>(), get<_i6.Websocket>()));
  gh.lazySingleton<_i6.BoltCardRepository>(
      () => _i38.MockBoltCardRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i39.BoltCardRepository>(
      () => _i39.BoltCardRepositoryImpl(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i40.ContactRepository>(
      () => _i40.ContactRepositoryImpl(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.ContactRepository>(
      () => _i41.MockContactRepository(
          get<_i10.Config>(), get<_i13.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i42.CurrencyRepository>(
      () => _i42.CurrencyRepositoryImpl(get<_i13.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i6.CurrencyRepository>(
      () => _i43.MockCurrencyRepository(get<_i13.Dio>()),
      registerFor: {_mock});
  return get;
}

class _$RegisterModule extends _i44.RegisterModule {}
