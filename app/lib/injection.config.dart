// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i14;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i10;
import 'config/index.dart' as _i15;
import 'data/dio/dio.client.dart' as _i45;
import 'data/index.dart' as _i5;
import 'data/mock/repository/auth.repository.dart' as _i6;
import 'data/mock/repository/currency.repository.dart' as _i37;
import 'data/mock/repository/entity/action.repository.dart' as _i43;
import 'data/mock/repository/entity/bolt_card.repository.dart' as _i33;
import 'data/mock/repository/entity/contact.repository.dart' as _i35;
import 'data/mock/repository/entity/pot.repository.dart' as _i38;
import 'data/mock/repository/entity/receiver.repository.dart' as _i39;
import 'data/mock/repository/entity/transaction.repository.dart' as _i40;
import 'data/mock/repository/entity/user-device.repository.dart' as _i41;
import 'data/mock/repository/entity/user.repository.dart' as _i42;
import 'data/mock/repository/websocket.dart' as _i30;
import 'data/repository/auth.repository.dart' as _i7;
import 'data/repository/currency.repository.dart' as _i36;
import 'data/repository/entity/action.repository.dart' as _i31;
import 'data/repository/entity/bolt_card.repository.dart' as _i32;
import 'data/repository/entity/contact.repository.dart' as _i34;
import 'data/repository/entity/pot.repository.dart' as _i20;
import 'data/repository/entity/receiver.repository.dart' as _i22;
import 'data/repository/entity/transaction.repository.dart' as _i25;
import 'data/repository/entity/user-device.repository.dart' as _i27;
import 'data/repository/entity/user.repository.dart' as _i28;
import 'data/repository/websocket.dart' as _i29;
import 'logic/bloc/action.cubit.dart' as _i3;
import 'logic/bloc/action_trigger.service.dart' as _i4;
import 'logic/bloc/auth.cubit.dart' as _i44;
import 'logic/bloc/currency_input.cubit.dart' as _i12;
import 'logic/bloc/current_pot.service.dart' as _i13;
import 'logic/bloc/entity/bolt_card.cubit.dart' as _i8;
import 'logic/bloc/entity/contact.cubit.dart' as _i11;
import 'logic/bloc/entity/pot.cubit.dart' as _i19;
import 'logic/bloc/entity/receiver.cubit.dart' as _i21;
import 'logic/bloc/entity/transaction.cubit.dart' as _i23;
import 'logic/bloc/entity/user.cubit.dart' as _i26;
import 'logic/bloc/transaction-listener/clipboard_listener.dart' as _i9;
import 'logic/bloc/transaction-listener/link_listener.dart' as _i16;
import 'logic/bloc/transaction-listener/nfc_listener.dart' as _i18;
import 'logic/bloc/transaction-listener/transaction_listener.cubit.dart'
    as _i24;
import 'logic/nfc.cubit.dart' as _i17;

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
  gh.factory<_i3.ActionLoader>(() => _i3.ActionLoader(get<String>()));
  gh.lazySingleton<_i4.ActionTriggerService>(() => _i4.ActionTriggerService());
  gh.factory<_i5.AuthRepository>(() => _i6.MockAuthRepository(),
      registerFor: {_mock});
  gh.factory<_i7.AuthRepository>(() => _i7.AuthRepositoryImpl(),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i8.BoltCardCubit>(() => _i8.BoltCardCubit());
  gh.singleton<_i9.ClipboardListener>(_i9.ClipboardListener());
  gh.factory<_i10.Config>(() => _i10.DevConfig(), registerFor: {_dev});
  gh.factory<_i10.Config>(() => _i10.TestConfig(), registerFor: {_test});
  gh.factory<_i10.Config>(() => _i10.StagingConfig(), registerFor: {_staging});
  gh.factory<_i10.Config>(() => _i10.ProdConfig(), registerFor: {_prod});
  gh.factory<_i10.Config>(() => _i10.MockConfig(), registerFor: {_mock});
  gh.factory<_i11.ContactCubit>(() => _i11.ContactCubit());
  gh.factory<_i12.CurrencyInputCubit>(
      () => _i12.CurrencyInputCubit(get<_i12.CurrencyInputOptions>()));
  gh.lazySingleton<_i13.CurrentPotService>(() => _i13.CurrentPotService());
  gh.lazySingleton<_i14.Dio>(() => registerModule.dio(get<_i15.Config>()));
  gh.singleton<_i16.LinkListener>(_i16.LinkListener());
  gh.factory<_i17.NFCCubit>(() => _i17.NFCCubit());
  gh.singleton<_i18.NFCListener>(_i18.NFCListener());
  gh.factory<_i19.PotCubit>(() => _i19.PotCubit());
  gh.lazySingleton<_i20.PotRepository>(
      () => _i20.PotRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i21.ReceiverCubit>(() => _i21.ReceiverCubit());
  gh.lazySingleton<_i22.ReceiverRepository>(
      () => _i22.ReceiverRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i23.TransactionCubit>(() => _i23.TransactionCubit());
  gh.factory<_i24.TransactionListenerCubit>(
      () => _i24.TransactionListenerCubit());
  gh.lazySingleton<_i25.TransactionRepository>(
      () => _i25.TransactionRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i26.UserCubit>(() => _i26.UserCubit());
  gh.lazySingleton<_i27.UserDeviceRepository>(
      () => _i27.UserDeviceRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i28.UserRepository>(
      () => _i28.UserRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i29.Websocket>(_i29.WebsocketImpl(get<_i15.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i5.Websocket>(_i30.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i31.ActionRepository>(
      () => _i31.ActionRepositoryImpl(get<_i14.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i32.BoltCardRepository>(
      () => _i32.BoltCardRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i5.BoltCardRepository>(
      () => _i33.MockBoltCardRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i34.ContactRepository>(
      () => _i34.ContactRepositoryImpl(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i5.ContactRepository>(
      () => _i35.MockContactRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i36.CurrencyRepository>(
      () => _i36.CurrencyRepositoryImpl(get<_i14.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i5.CurrencyRepository>(
      () => _i37.MockCurrencyRepository(get<_i14.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i5.PotRepository>(
      () => _i38.MockPotRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i5.ReceiverRepository>(
      () => _i39.MockReceiveRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i5.TransactionRepository>(
      () => _i40.MockTransactionRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i5.UserDeviceRepository>(
      () => _i41.MockUserDeviceRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i5.UserRepository>(
      () => _i42.MockUserRepository(
          get<_i15.Config>(), get<_i14.Dio>(), get<_i5.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i5.ActionRepository>(
      () => _i43.MockActionRepository(get<_i5.ReceiverRepository>(),
          get<_i5.TransactionRepository>(), get<_i14.Dio>()),
      registerFor: {_mock});
  gh.singleton<_i44.AuthCubit>(_i44.AuthCubit(get<_i5.AuthRepository>(),
      get<_i5.UserRepository>(), get<_i5.Websocket>()));
  return get;
}

class _$RegisterModule extends _i45.RegisterModule {}
