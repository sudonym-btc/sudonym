import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class CubitWrapper<
    C extends EntityCubit<CrudRepository<T>, EntityCubitState<T>, T>,
    T extends BaseClass> extends StatelessWidget {
  final T entity;
  final bool fetch;
  final Function builder;

  const CubitWrapper(
      {required this.entity,
      required this.builder,
      this.fetch = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            C c = getIt.get<C>();
            c.set(entity);
            if (fetch) {
              c.fetch(entity.toJson()['id']);
            }
            return c;
          })
        ],
        child: BlocBuilder<C, dynamic>(builder: (BuildContext context, state) {
          return builder(context, state);
        }));
  }
}
