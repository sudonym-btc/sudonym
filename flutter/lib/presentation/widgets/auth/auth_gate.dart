import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';

import '../../../injection.dart';
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
              print(state.user?.id);
              return const HomePage();
            }
            return const SigninPage();
          },
        ));
  }
}
