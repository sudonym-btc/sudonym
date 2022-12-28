// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i15;
import 'package:flutter/material.dart' as _i24;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:sudonym.models/index.dart' as _i23;

import 'config/config.dart' as _i11;
import 'config/index.dart' as _i16;
import 'data/dio/dio.client.dart' as _i58;
import 'data/index.dart' as _i6;
import 'data/mock/repository/auth.repository.dart' as _i7;
import 'data/mock/repository/currency.repository.dart' as _i48;
import 'data/mock/repository/entity/action.repository.dart' as _i56;
import 'data/mock/repository/entity/bill_split.respository.dart' as _i42;
import 'data/mock/repository/entity/bolt_card.repository.dart' as _i43;
import 'data/mock/repository/entity/contact.repository.dart' as _i46;
import 'data/mock/repository/entity/pot.repository.dart' as _i49;
import 'data/mock/repository/entity/pot_user.repository.dart' as _i50;
import 'data/mock/repository/entity/receiver.repository.dart' as _i51;
import 'data/mock/repository/entity/sender.repository.dart' as _i52;
import 'data/mock/repository/entity/transaction.repository.dart' as _i53;
import 'data/mock/repository/entity/user-device.repository.dart' as _i54;
import 'data/mock/repository/entity/user.repository.dart' as _i55;
import 'data/mock/repository/websocket.dart' as _i39;
import 'data/repository/auth.repository.dart' as _i5;
import 'data/repository/currency.repository.dart' as _i47;
import 'data/repository/entity/action.repository.dart' as _i40;
import 'data/repository/entity/bill_split.repository.dart' as _i41;
import 'data/repository/entity/bolt_card.repository.dart' as _i44;
import 'data/repository/entity/contact.repository.dart' as _i45;
import 'data/repository/entity/pot.repository.dart' as _i25;
import 'data/repository/entity/pot_user.repository.dart' as _i26;
import 'data/repository/entity/receiver.repository.dart' as _i28;
import 'data/repository/entity/sender.repository.dart' as _i30;
import 'data/repository/entity/transaction.repository.dart' as _i34;
import 'data/repository/entity/user-device.repository.dart' as _i36;
import 'data/repository/entity/user.repository.dart' as _i37;
import 'data/repository/websocket.dart' as _i38;
import 'logic/bloc/action.cubit.dart' as _i3;
import 'logic/bloc/action_trigger.service.dart' as _i4;
import 'logic/bloc/auth.cubit.dart' as _i57;
import 'logic/bloc/currency_input.cubit.dart' as _i13;
import 'logic/bloc/current_pot.service.dart' as _i14;
import 'logic/bloc/entity/bill_split.cubit.dart' as _i8;
import 'logic/bloc/entity/bolt_card.cubit.dart' as _i9;
import 'logic/bloc/entity/contact.cubit.dart' as _i12;
import 'logic/bloc/entity/pot.cubit.dart' as _i20;
import 'logic/bloc/entity/receiver.cubit.dart' as _i27;
import 'logic/bloc/entity/sender.cubit.dart' as _i29;
import 'logic/bloc/entity/transaction.cubit.dart' as _i31;
import 'logic/bloc/entity/user.cubit.dart' as _i35;
import 'logic/bloc/pot_list_reorganizer.cubit.dart' as _i21;
import 'logic/bloc/transaction-listener/clipboard_listener.dart' as _i10;
import 'logic/bloc/transaction-listener/link_listener.dart' as _i17;
import 'logic/bloc/transaction-listener/nfc_listener.dart' as _i19;
import 'logic/bloc/transaction-listener/transaction_listener.cubit.dart'
    as _i33;
import 'logic/bloc/transaction_handler.service.dart' as _i32;
import 'logic/index.dart' as _i22;
import 'logic/nfc.cubit.dart' as _i18;

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
  gh.factory<_i8.BillSplitCubit>(() => _i8.BillSplitCubit());
  gh.factory<_i9.BoltCardCubit>(() => _i9.BoltCardCubit());
  gh.singleton<_i10.ClipboardListener>(_i10.ClipboardListener());
  gh.factory<_i11.Config>(() => _i11.DevConfig(), registerFor: {_dev});
  gh.factory<_i11.Config>(() => _i11.TestConfig(), registerFor: {_test});
  gh.factory<_i11.Config>(() => _i11.StagingConfig(), registerFor: {_staging});
  gh.factory<_i11.Config>(() => _i11.ProdConfig(), registerFor: {_prod});
  gh.factory<_i11.Config>(() => _i11.MockConfig(), registerFor: {_mock});
  gh.factory<_i12.ContactCubit>(() => _i12.ContactCubit());
  gh.factory<_i13.CurrencyInputCubit>(
      () => _i13.CurrencyInputCubit(get<_i13.CurrencyInputOptions>()));
  gh.lazySingleton<_i14.CurrentPotService>(() => _i14.CurrentPotService());
  gh.lazySingleton<_i15.Dio>(() => registerModule.dio(get<_i16.Config>()));
  gh.singleton<_i17.LinkListener>(_i17.LinkListener());
  gh.factory<_i18.NFCCubit>(() => _i18.NFCCubit());
  gh.singleton<_i19.NFCListener>(_i19.NFCListener());
  gh.factory<_i20.PotCubit>(() => _i20.PotCubit());
  gh.factory<_i21.PotListReorganizerCubit>(() => _i21.PotListReorganizerCubit(
      list: get<_i22.ListCubit<_i23.Pot>>(),
      controller: get<_i24.PageController>()));
  gh.lazySingleton<_i25.PotRepository>(
      () => _i25.PotRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i26.PotUserRepository>(
      () => _i26.PotUserRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i27.ReceiverCubit>(() => _i27.ReceiverCubit());
  gh.lazySingleton<_i28.ReceiverRepository>(
      () => _i28.ReceiverRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i29.SenderCubit>(() => _i29.SenderCubit());
  gh.lazySingleton<_i30.SenderRepository>(
      () => _i30.SenderRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i31.TransactionCubit>(() => _i31.TransactionCubit());
  gh.lazySingleton<_i32.TransactionHandlerService>(
      () => _i32.TransactionHandlerService());
  gh.factory<_i33.TransactionListenerCubit>(
      () => _i33.TransactionListenerCubit());
  gh.lazySingleton<_i34.TransactionRepository>(
      () => _i34.TransactionRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i35.UserCubit>(() => _i35.UserCubit());
  gh.lazySingleton<_i36.UserDeviceRepository>(
      () => _i36.UserDeviceRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i37.UserRepository>(
      () => _i37.UserRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i38.Websocket>(_i38.WebsocketImpl(get<_i16.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i6.Websocket>(_i39.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i40.ActionRepository>(
      () => _i40.ActionRepositoryImpl(get<_i15.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i41.BillSplitRepository>(
      () => _i41.BillSplitRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.BillSplitRepository>(
      () => _i42.MockBillSplitRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.BoltCardRepository>(
      () => _i43.MockBoltCardRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i44.BoltCardRepository>(
      () => _i44.BoltCardRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i45.ContactRepository>(
      () => _i45.ContactRepositoryImpl(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.ContactRepository>(
      () => _i46.MockContactRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i47.CurrencyRepository>(
      () => _i47.CurrencyRepositoryImpl(get<_i15.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i6.CurrencyRepository>(
      () => _i48.MockCurrencyRepository(get<_i15.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.PotRepository>(
      () => _i49.MockPotRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.PotUserRepository>(
      () => _i50.MockPotUserRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.ReceiverRepository>(
      () => _i51.MockReceiveRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.SenderRepository>(
      () => _i52.MockSenderRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.TransactionRepository>(
      () => _i53.MockTransactionRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.UserDeviceRepository>(
      () => _i54.MockUserDeviceRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.UserRepository>(
      () => _i55.MockUserRepository(
          get<_i16.Config>(), get<_i15.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.ActionRepository>(
      () => _i56.MockActionRepository(get<_i6.ReceiverRepository>(),
          get<_i6.TransactionRepository>(), get<_i15.Dio>()),
      registerFor: {_mock});
  gh.singleton<_i57.AuthCubit>(_i57.AuthCubit(get<_i6.AuthRepository>(),
      get<_i6.UserRepository>(), get<_i6.Websocket>()));
  return get;
}

class _$RegisterModule extends _i58.RegisterModule {}
