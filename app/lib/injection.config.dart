// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'config/config.dart' as _i6;
import 'data/dio/dio.client.dart' as _i35;
import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/contact.repository.dart' as _i19;
import 'data/mock/repository/currency.repository.dart' as _i21;
import 'data/mock/repository/pay.repository.dart' as _i32;
import 'data/mock/repository/pot.repository.dart' as _i24;
import 'data/mock/repository/receive.repository.dart' as _i11;
import 'data/mock/repository/transaction.repository.dart' as _i27;
import 'data/mock/repository/user.repository.dart' as _i30;
import 'data/mock/repository/websocket.dart' as _i16;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/contact.repository.dart' as _i18;
import 'data/repository/currency.repository.dart' as _i20;
import 'data/repository/pay.repository.dart' as _i8;
import 'data/repository/pot.repository.dart' as _i23;
import 'data/repository/receive.repository.dart' as _i10;
import 'data/repository/transaction.repository.dart' as _i26;
import 'data/repository/user.repository.dart' as _i29;
import 'data/repository/websocket.dart' as _i15;
import 'logic/bloc/auth.cubit.dart' as _i17;
import 'logic/bloc/contact.cubit.dart' as _i31;
import 'logic/bloc/link.service.dart' as _i22;
import 'logic/bloc/pages/home/pot_slider.cubit.dart' as _i9;
import 'logic/bloc/pot.cubit.dart' as _i33;
import 'logic/bloc/receive.cubit.dart' as _i25;
import 'logic/bloc/send.cubit.dart' as _i12;
import 'logic/bloc/transaction-listener/clipboard-listener.dart' as _i5;
import 'logic/bloc/transaction-listener/transaction-listener.cubit.dart'
    as _i13;
import 'logic/bloc/transaction.cubit.dart' as _i34;
import 'logic/bloc/transactions.cubit.dart' as _i28;
import 'logic/bloc/user.cubit.dart' as _i14;

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
  gh.factory<_i6.Config>(() => _i6.DevConfig(), registerFor: {_dev});
  gh.factory<_i6.Config>(() => _i6.ProdConfig(), registerFor: {_prod});
  gh.factory<_i6.Config>(() => _i6.MockConfig(), registerFor: {_mock});
  gh.lazySingleton<_i7.Dio>(() => registerModule.dio(get<_i6.Config>()));
  gh.lazySingleton<_i8.PayRepository>(
      () => _i8.PayRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i9.PotSliderCubit>(() => _i9.PotSliderCubit(get<int>()));
  gh.lazySingleton<_i10.ReceiveRepository>(
      () => _i10.ReceiveRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.lazySingleton<_i10.ReceiveRepository>(
      () => _i11.MockReceiveRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i12.SendCubit>(() => _i12.SendCubit(get<_i8.PayRepository>()));
  gh.factory<_i13.TransactionListenerCubit>(
      () => _i13.TransactionListenerCubit());
  gh.factory<_i14.UserCubit>(() => _i14.UserCubit());
  gh.singleton<_i15.Websocket>(_i16.MockWebsocket(), registerFor: {_mock});
  gh.singleton<_i15.Websocket>(_i15.WebsocketImpl(get<_i6.Config>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i17.AuthCubit>(
      () => _i17.AuthCubit(get<_i3.AuthRepository>(), get<_i15.Websocket>()));
  gh.lazySingleton<_i18.ContactRepository>(
      () => _i19.MockContactRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i18.ContactRepository>(
      () => _i18.ContactRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.lazySingleton<_i20.CurrencyRepository>(
      () => _i20.CurrencyRepositoryImpl(get<_i7.Dio>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i20.CurrencyRepository>(
      () => _i21.MockCurrencyRepository(get<_i7.Dio>()),
      registerFor: {_mock});
  gh.lazySingleton<_i22.LinkService>(
      () => _i22.LinkService(get<_i8.PayRepository>()));
  gh.lazySingleton<_i23.PotRepository>(
      () => _i24.MockPotRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.lazySingleton<_i23.PotRepository>(
      () => _i23.PotRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.factory<_i25.ReceiveCubit>(
      () => _i25.ReceiveCubit(get<_i10.ReceiveRepository>()));
  gh.lazySingleton<_i26.TransactionRepository>(
      () => _i26.TransactionRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.lazySingleton<_i26.TransactionRepository>(
      () => _i27.MockTransactionRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i28.TransactionsCubit>(
      () => _i28.TransactionsCubit(get<_i26.TransactionRepository>()));
  gh.lazySingleton<_i29.UserRepository>(
      () => _i29.UserRepositoryImpl(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_dev, _staging, _prod});
  gh.lazySingleton<_i29.UserRepository>(
      () => _i30.MockUserRepository(
          get<_i6.Config>(), get<_i7.Dio>(), get<_i15.Websocket>()),
      registerFor: {_mock});
  gh.factory<_i31.ContactCubit>(
      () => _i31.ContactCubit(get<_i18.ContactRepository>()));
  gh.lazySingleton<_i8.PayRepository>(
      () => _i32.MockPayRepository(get<_i10.ReceiveRepository>(),
          get<_i26.TransactionRepository>(), get<_i7.Dio>()),
      registerFor: {_mock});
  gh.factory<_i33.PotCubit>(() => _i33.PotCubit(get<_i23.PotRepository>()));
  gh.factory<_i34.TransactionCubit>(
      () => _i34.TransactionCubit(get<_i26.TransactionRepository>()));
  return get;
}

class _$RegisterModule extends _i35.RegisterModule {}
