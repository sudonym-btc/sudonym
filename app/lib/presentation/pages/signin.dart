import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SignInButton(
          Buttons.Google,
          onPressed: context.read<AuthCubit>().loginWithGoogle,
        ),
        SignInButton(
          Buttons.Facebook,
          onPressed: context.read<AuthCubit>().loginWithFacebook,
        )
      ],
    )));
  }
}
