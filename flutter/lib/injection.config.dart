// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'data/mock/repository/auth.repository.dart' as _i4;
import 'data/mock/repository/pot.repository.dart' as _i6;
import 'data/mock/repository/transation.repository.dart' as _i8;
import 'data/repository/auth.repository.dart' as _i3;
import 'data/repository/pot.repository.dart' as _i5;
import 'data/repository/transaction.repository.dart' as _i7;
import 'logic/bloc/auth.cubit.dart' as _i9;

const String _prod = 'prod';
const String _dev = 'dev';
// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.factory<_i3.AuthRepository>(() => _i3.AuthRepositoryImpl(),
      registerFor: {_prod});
  gh.factory<_i3.AuthRepository>(() => _i4.MockAuthRepository(),
      registerFor: {_dev});
  gh.factory<_i5.PotRepository>(() => _i5.PotRepositoryImpl(),
      registerFor: {_prod});
  gh.factory<_i5.PotRepository>(() => _i6.MockPotRepository(),
      registerFor: {_dev});
  gh.factory<_i7.TransactionRepository>(() => _i7.TransactionRepositoryImpl(),
      registerFor: {_prod});
  gh.factory<_i7.TransactionRepository>(() => _i8.MockTransactionRepository(),
      registerFor: {_dev});
  gh.factory<_i9.AuthCubit>(() => _i9.AuthCubit(get<_i3.AuthRepository>()));
  return get;
}
