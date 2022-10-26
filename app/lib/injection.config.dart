// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i8;
import 'data/dio/dio.client.dart' as _i44;
import 'data/index.dart' as _i3;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/currency.repository.dart' as _i39;
import 'data/mock/repository/entity/action.repository.dart' as _i31;
import 'data/mock/repository/entity/bolt_card.repository.dart' as _i36;
import 'data/mock/repository/entity/contact.repository.dart' as _i37;
import 'data/mock/repository/entity/pot.repository.dart' as _i16;
import 'data/mock/repository/entity/receiver.repository.dart' as _i19;
import 'data/mock/repository/entity/transaction.repository.dart' as _i23;
import 'data/mock/repository/entity/user-device.repository.dart' as _i26;
import 'data/mock/repository/entity/user.repository.dart' as _i27;
import 'data/mock/repository/websocket.dart' as _i30;
import 'data/repository/auth.repository.dart' as _i5;
import 'data/repository/currency.repository.dart' as _i40;
import 'data/repository/entity/action.repository.dart' as _i32;
import 'data/repository/entity/bolt_card.repository.dart' as _i35;
import 'data/repository/entity/contact.repository.dart' as _i38;
import 'data/repository/entity/pot.repository.dart' as _i41;
import 'data/repository/entity/receiver.repository.dart' as _i18;
import 'data/repository/entity/transaction.repository.dart' as _i22;
import 'data/repository/entity/user-device.repository.dart' as _i25;
import 'data/repository/entity/user.repository.dart' as _i28;
import 'data/repository/websocket.dart' as _i29;
import 'logic/bloc/action_trigger.service.dart' as _i33;
import 'logic/bloc/auth.cubit.dart' as _i34;
import 'logic/bloc/currency_input.cubit.dart' as _i10;
import 'logic/bloc/entity/bolt_card.cubit.dart' as _i6;
import 'logic/bloc/entity/contact.cubit.dart' as _i9;
import 'logic/bloc/entity/pot.cubit.dart' as _i15;
import 'logic/bloc/entity/receiver.cubit.dart' as _i17;
import 'logic/bloc/entity/transaction.cubit.dart' as _i20;
import 'logic/bloc/entity/user.cubit.dart' as _i24;
import 'logic/bloc/pages/send.cubit.dart' as _i42;
import 'logic/bloc/pages/withdraw.cubit.dart' as _i43;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i7;
import 'logic/bloc/transaction-listener/link-listener.dart' as _i12;
import 'logic/bloc/transaction-listener/nfc-listener.dart' as _i14;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i21;
import 'logic/nfc.cubit.dart' as _i13;

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
  gh.factory<_i5.AuthRepository>(() => _i5.AuthRepositoryImpl(),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i6.BoltCardCubit>(() => _i6.BoltCardCubit());
  gh.factory<_i7.ClipboardListener>(() => _i7.ClipboardListener());
  gh.factory<_i8.Config>(() => _i8.DevConfig(), registerFor: {_dev});
  gh.factory<_i8.Config>(() => _i8.TestConfig(), registerFor: {_test});
  gh.factory<_i8.Config>(() => _i8.MockConfig(), registerFor: {_mock});
  gh.factory<_i8.Config>(() => _i8.StagingConfig(), registerFor: {_staging});
  gh.factory<_i8.Config>(() => _i8.ProdConfig(), registerFor: {_prod});
  gh.factory<_i9.ContactCubit>(() => _i9.ContactCubit());
  gh.factory<_i10.CurrencyInputCubit>(
      () => _i10.CurrencyInputCubit(get<_i10.CurrencyInputOptions>()));
  gh.lazySingleton<_i11.Dio>(() => registerModule.dio(get<_i8.Config>()));
  gh.factory<_i12.LinkListener>(() => _i12.LinkListener());
  gh.factory<_i13.NFCCubit>(() => _i13.NFCCubit());
  gh.factory<_i14.NFCListener>(() => _i14.NFCListener());
  gh.factory<_i15.PotCubit>(() => _i15.PotCubit());
  gh.lazySingleton<_i3.PotRepository>(
      () => _i16.MockPotRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i17.ReceiverCubit>(() => _i17.ReceiverCubit());
  gh.lazySingleton<_i18.ReceiverRepository>(
      () => _i18.ReceiverRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i3.ReceiverRepository>(
      () => _i19.MockReceiveRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i20.TransactionCubit>(() => _i20.TransactionCubit());
  gh.factory<_i21.TransactionListenerCubit>(
      () => _i21.TransactionListenerCubit());
  gh.lazySingleton<_i22.TransactionRepository>(
      () => _i22.TransactionRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i3.TransactionRepository>(
      () => _i23.MockTransactionRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i24.UserCubit>(() => _i24.UserCubit());
  gh.lazySingleton<_i25.UserDeviceRepository>(
      () => _i25.UserDeviceRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i3.UserDeviceRepository>(
      () => _i26.MockUserDeviceRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i3.UserRepository>(
      () => _i27.MockUserRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i28.UserRepository>(
      () => _i28.UserRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i29.Websocket>(_i29.WebsocketImpl(get<_i8.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i29.Websocket>(_i30.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i3.ActionRepository>(
      () => _i31.MockActionRepository(get<_i3.ReceiverRepository>(),
          get<_i3.TransactionRepository>(), get<_i11.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i32.ActionRepository>(
      () => _i32.ActionRepositoryImpl(get<_i11.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i33.ActionTriggerService>(
      () => _i33.ActionTriggerService(get<_i3.ActionRepository>()));
  gh.singleton<_i34.AuthCubit>(_i34.AuthCubit(get<_i3.AuthRepository>(),
      get<_i3.UserRepository>(), get<_i3.Websocket>()));
  gh.factory<_i35.BoltCardRepository>(
      () => _i35.BoltCardRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i3.BoltCardRepository>(
      () => _i36.MockBoltCardRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i3.ContactRepository>(
      () => _i37.MockContactRepository(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i38.ContactRepository>(
      () => _i38.ContactRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i3.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i3.CurrencyRepository>(
      () => _i39.MockCurrencyRepository(get<_i11.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i40.CurrencyRepository>(
      () => _i40.CurrencyRepositoryImpl(get<_i11.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i41.PotRepository>(
      () => _i41.PotRepositoryImpl(
          get<_i8.Config>(), get<_i11.Dio>(), get<_i29.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i42.SendCubit>(() => _i42.SendCubit(get<_i3.ActionRepository>()));
  gh.factory<_i43.WithdrawCubit>(
      () => _i43.WithdrawCubit(get<_i3.ActionRepository>()));
  return get;
}

class _$RegisterModule extends _i44.RegisterModule {}
