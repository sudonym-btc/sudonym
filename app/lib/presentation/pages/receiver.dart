import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';

class ReceiverPage extends StatelessWidget {
  final Receiver receiver;
  const ReceiverPage(this.receiver, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ReceiverCubit()..fetch(receiver.id))
        ],
        child: BlocBuilder<ReceiverCubit, ReceiverCubitState>(
            builder: ((context, state) {
          return Text("Receiver");
        })));
  }
}
