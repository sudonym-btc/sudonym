import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/index.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          child: MultiBlocProvider(
            providers: [BlocProvider(create: (_) => ContactCubit())],
            child: BlocBuilder<ContactCubit, ContactCubitState>(
                builder: ((context, state) {
              return const Text('contact');
            })),
          ),
        ));
  }
}
