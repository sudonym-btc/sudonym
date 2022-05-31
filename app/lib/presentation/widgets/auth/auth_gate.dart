import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';

import '../../../injection.dart';
import '../../../logic/bloc/transaction-listener/transaction-listener.cubit.dart';
import '../../pages/home_page.dart';
import '../../pages/signin.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<AuthCubit>())],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // Render application if authenticated
            if (state is LoadedState && state.user != null) {
              return MultiBlocProvider(providers: [
                BlocProvider(create: (_) => getIt<TransactionListenerCubit>())
              ], child: _LoggedInWidget());
            }
            return const SigninPage();
          },
        ));
  }
}

class _LoggedInWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionListenerCubit,
            TransactionListenerCubitState>(
        bloc: BlocProvider.of<TransactionListenerCubit>(context),
        listener: (BuildContext context, state) {
          final snackBar = SnackBar(
            content: Text('Detected address in clipboard'),
            action: SnackBarAction(
                label: 'Send',
                onPressed: () {
                  Navigator.pushNamed(context, '/confirmSend');
                }),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: const HomePage());
  }
}
