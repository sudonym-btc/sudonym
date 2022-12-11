import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

class CubitWrapper<
    C extends EntityCubit<CrudRepository<T>, CS, T>,
    CS extends EntityCubitState<T>,
    T extends BaseClass> extends StatelessWidget {
  final T entity;
  final bool fetch;
  final bool Function(CS state)? refresh;
  final Widget Function(BuildContext context, CS state) builder;
  final Function(BuildContext context, CS state)? listener;

  const CubitWrapper(
      {required this.entity,
      required this.builder,
      this.listener,
      this.refresh,
      this.fetch = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        key: ValueKey(entity.toJson()['id'].toString()),
        create: (_) {
          C c = getIt.get<C>();

          // If meant to remote fetch, don't set entity as we can show loader during this time
          // If entity already set, deciding when to show loader is more difficult
          if (fetch) {
            c.fetch(entity.toJson()['id']);
          } else {
            c.set(entity);
          }
          if (refresh != null) {
            c.setRefresher(const Duration(seconds: 10), refresh!);
          }
          return c;
        },
        lazy: false,
        child: BlocConsumer<C, CS>(
          builder: builder,
          listener: listener ?? (context, state) => {},
        ));
  }
}
