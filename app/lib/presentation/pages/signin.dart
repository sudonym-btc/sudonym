import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(padding * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Subtitle(AppLocalizations.of(context)!.welcomeTo),
                  const Header("Sudonym")
                ],
              )),
          Expanded(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.signInWith),
              Container(height: padding * 2),
              Button(
                text: "Google",
                onPressed: context.read<AuthCubit>().loginWithGoogle,
              ),
              Container(height: padding),
              Button(
                text: "Facebook",
                onPressed: context.read<AuthCubit>().loginWithFacebook,
              )
              // SignInButton(
              //   Buttons.Google,
              // ),
              // SignInButton(
              //   Buttons.Facebook,
              // )
            ],
          )))
        ]));
  }
}
