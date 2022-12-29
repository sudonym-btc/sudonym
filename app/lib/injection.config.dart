// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i16;
import 'package:flutter/material.dart' as _i25;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:sudonym.models/index.dart' as _i24;

import 'config/config.dart' as _i12;
import 'config/index.dart' as _i17;
import 'data/dio/dio.client.dart' as _i61;
import 'data/index.dart' as _i6;
import 'data/mock/repository/auth.repository.dart' as _i7;
import 'data/mock/repository/currency.repository.dart' as _i51;
import 'data/mock/repository/entity/action.repository.dart' as _i59;
import 'data/mock/repository/entity/bill_split.respository.dart' as _i45;
import 'data/mock/repository/entity/bill_split_participant.respository.dart'
    as _i43;
import 'data/mock/repository/entity/bolt_card.repository.dart' as _i46;
import 'data/mock/repository/entity/contact.repository.dart' as _i48;
import 'data/mock/repository/entity/pot.repository.dart' as _i52;
import 'data/mock/repository/entity/pot_user.repository.dart' as _i53;
import 'data/mock/repository/entity/receiver.repository.dart' as _i54;
import 'data/mock/repository/entity/sender.repository.dart' as _i55;
import 'data/mock/repository/entity/transaction.repository.dart' as _i56;
import 'data/mock/repository/entity/user-device.repository.dart' as _i57;
import 'data/mock/repository/entity/user.repository.dart' as _i58;
import 'data/mock/repository/websocket.dart' as _i40;
import 'data/repository/auth.repository.dart' as _i5;
import 'data/repository/currency.repository.dart' as _i50;
import 'data/repository/entity/action.repository.dart' as _i41;
import 'data/repository/entity/bill_split.repository.dart' as _i44;
import 'data/repository/entity/bill_split_participant.repository.dart' as _i42;
import 'data/repository/entity/bolt_card.repository.dart' as _i47;
import 'data/repository/entity/contact.repository.dart' as _i49;
import 'data/repository/entity/pot.repository.dart' as _i26;
import 'data/repository/entity/pot_user.repository.dart' as _i27;
import 'data/repository/entity/receiver.repository.dart' as _i29;
import 'data/repository/entity/sender.repository.dart' as _i31;
import 'data/repository/entity/transaction.repository.dart' as _i35;
import 'data/repository/entity/user-device.repository.dart' as _i37;
import 'data/repository/entity/user.repository.dart' as _i38;
import 'data/repository/websocket.dart' as _i39;
import 'logic/bloc/action.cubit.dart' as _i3;
import 'logic/bloc/action_trigger.service.dart' as _i4;
import 'logic/bloc/auth.cubit.dart' as _i60;
import 'logic/bloc/currency_input.cubit.dart' as _i14;
import 'logic/bloc/current_pot.service.dart' as _i15;
import 'logic/bloc/entity/bill_split.cubit.dart' as _i8;
import 'logic/bloc/entity/bill_split_participant.cubit.dart' as _i9;
import 'logic/bloc/entity/bolt_card.cubit.dart' as _i10;
import 'logic/bloc/entity/contact.cubit.dart' as _i13;
import 'logic/bloc/entity/pot.cubit.dart' as _i21;
import 'logic/bloc/entity/receiver.cubit.dart' as _i28;
import 'logic/bloc/entity/sender.cubit.dart' as _i30;
import 'logic/bloc/entity/transaction.cubit.dart' as _i32;
import 'logic/bloc/entity/user.cubit.dart' as _i36;
import 'logic/bloc/pot_list_reorganizer.cubit.dart' as _i22;
import 'logic/bloc/transaction-listener/clipboard_listener.dart' as _i11;
import 'logic/bloc/transaction-listener/link_listener.dart' as _i18;
import 'logic/bloc/transaction-listener/nfc_listener.dart' as _i20;
import 'logic/bloc/transaction-listener/transaction_listener.cubit.dart'
    as _i34;
import 'logic/bloc/transaction_handler.service.dart' as _i33;
import 'logic/index.dart' as _i23;
import 'logic/nfc.cubit.dart' as _i19;

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
  gh.factory<_i9.BillSplitParticipantCubit>(
      () => _i9.BillSplitParticipantCubit());
  gh.factory<_i10.BoltCardCubit>(() => _i10.BoltCardCubit());
  gh.singleton<_i11.ClipboardListener>(_i11.ClipboardListener());
  gh.factory<_i12.Config>(() => _i12.DevConfig(), registerFor: {_dev});
  gh.factory<_i12.Config>(() => _i12.TestConfig(), registerFor: {_test});
  gh.factory<_i12.Config>(() => _i12.StagingConfig(), registerFor: {_staging});
  gh.factory<_i12.Config>(() => _i12.ProdConfig(), registerFor: {_prod});
  gh.factory<_i12.Config>(() => _i12.MockConfig(), registerFor: {_mock});
  gh.factory<_i13.ContactCubit>(() => _i13.ContactCubit());
  gh.factory<_i14.CurrencyInputCubit>(
      () => _i14.CurrencyInputCubit(get<_i14.CurrencyInputOptions>()));
  gh.lazySingleton<_i15.CurrentPotService>(() => _i15.CurrentPotService());
  gh.lazySingleton<_i16.Dio>(() => registerModule.dio(get<_i17.Config>()));
  gh.singleton<_i18.LinkListener>(_i18.LinkListener());
  gh.factory<_i19.NFCCubit>(() => _i19.NFCCubit());
  gh.singleton<_i20.NFCListener>(_i20.NFCListener());
  gh.factory<_i21.PotCubit>(() => _i21.PotCubit());
  gh.factory<_i22.PotListReorganizerCubit>(() => _i22.PotListReorganizerCubit(
      list: get<_i23.ListCubit<_i24.Pot>>(),
      controller: get<_i25.PageController>()));
  gh.lazySingleton<_i26.PotRepository>(
      () => _i26.PotRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i27.PotUserRepository>(
      () => _i27.PotUserRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i28.ReceiverCubit>(() => _i28.ReceiverCubit());
  gh.lazySingleton<_i29.ReceiverRepository>(
      () => _i29.ReceiverRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i30.SenderCubit>(() => _i30.SenderCubit());
  gh.lazySingleton<_i31.SenderRepository>(
      () => _i31.SenderRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i32.TransactionCubit>(() => _i32.TransactionCubit());
  gh.lazySingleton<_i33.TransactionHandlerService>(
      () => _i33.TransactionHandlerService());
  gh.factory<_i34.TransactionListenerCubit>(
      () => _i34.TransactionListenerCubit());
  gh.lazySingleton<_i35.TransactionRepository>(
      () => _i35.TransactionRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i36.UserCubit>(() => _i36.UserCubit());
  gh.lazySingleton<_i37.UserDeviceRepository>(
      () => _i37.UserDeviceRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i38.UserRepository>(
      () => _i38.UserRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i39.Websocket>(_i39.WebsocketImpl(get<_i17.Config>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.singleton<_i6.Websocket>(_i40.MockWebsocket(), registerFor: {_mock});
  gh.lazySingleton<_i41.ActionRepository>(
      () => _i41.ActionRepositoryImpl(get<_i16.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i42.BillSplitParticipantRepository>(
      () => _i42.BillSplitParticipantRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.BillSplitParticipantRepository>(
      () => _i43.MockBillSplitParticipantRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i44.BillSplitRepository>(
      () => _i44.BillSplitRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.BillSplitRepository>(
      () => _i45.MockBillSplitRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.BoltCardRepository>(
      () => _i46.MockBoltCardRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i47.BoltCardRepository>(
      () => _i47.BoltCardRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i6.ContactRepository>(
      () => _i48.MockContactRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i49.ContactRepository>(
      () => _i49.ContactRepositoryImpl(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.lazySingleton<_i50.CurrencyRepository>(
      () => _i50.CurrencyRepositoryImpl(get<_i16.Dio>()),
      registerFor: {_dev, _test, _staging, _prod});
  gh.factory<_i6.CurrencyRepository>(
      () => _i51.MockCurrencyRepository(get<_i16.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.PotRepository>(
      () => _i52.MockPotRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.PotUserRepository>(
      () => _i53.MockPotUserRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.ReceiverRepository>(
      () => _i54.MockReceiveRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.SenderRepository>(
      () => _i55.MockSenderRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.TransactionRepository>(
      () => _i56.MockTransactionRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.UserDeviceRepository>(
      () => _i57.MockUserDeviceRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.UserRepository>(
      () => _i58.MockUserRepository(
          get<_i17.Config>(), get<_i16.Dio>(), get<_i6.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i6.ActionRepository>(
      () => _i59.MockActionRepository(get<_i6.ReceiverRepository>(),
          get<_i6.TransactionRepository>(), get<_i16.Dio>()),
      registerFor: {_mock});
  gh.singleton<_i60.AuthCubit>(_i60.AuthCubit(get<_i6.AuthRepository>(),
      get<_i6.UserRepository>(), get<_i6.Websocket>()));
  return get;
}

class _$RegisterModule extends _i61.RegisterModule {}
