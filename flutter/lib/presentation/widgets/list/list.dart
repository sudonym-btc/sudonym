import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';
import 'package:sudonym/logic/bloc/transactions.cubit.dart';
import 'package:sudonym/presentation/widgets/transactions/transaction.dart';

import '../../../injection.dart';

class List extends StatelessWidget {
  final String emptyText;
  final ListCubit list;
  final Function builder;

  const List(
      {required this.emptyText,
      required this.list,
      required this.builder,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => list)],
        child: BlocBuilder<ListCubit<dynamic>, ListCubitState<dynamic>>(
          builder: (context, state) {
            var children = <Widget>[];
            if (state.loading) {
              children.add(Center(
                  child: Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator())));
            }
            state.data.forEach((el) {
              children.add(Transaction(transaction: el));
            });
            return ListView(children: children);
          },
        ));
  }
}
