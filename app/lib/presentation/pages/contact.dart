import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/contact.repository.dart';
import '../../injection.dart';
import '../../logic/bloc/contact.cubit.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => ContactCubit(getIt<ContactRepository>()))
            ],
            child: BlocBuilder<ContactCubit, ContactCubitState>(
                builder: ((context, state) {
              return const Text('contact');
            })),
          ),
        ));
  }
}
