import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // Render application if authenticated
          if (state is LoadedState && state.user != null) {
            return MultiBlocProvider(providers: [
              BlocProvider(create: (_) => getIt<TransactionListenerCubit>())
            ], child: _LoggedInWidget(child: child));
          } else if (state.firebaseUser != null) {
            return const SplashPage();
          }
          return const SigninPage();
        },
      ),
    );
  }
}

class _LoggedInWidget extends StatefulWidget {
  final Widget child;
  const _LoggedInWidget({required this.child});
  @override
  State<StatefulWidget> createState() => _LoggedInWidgetState();
}

class _LoggedInWidgetState extends State<_LoggedInWidget> {
  @override
  void initState() {
    // getIt<ClipboardListener>().init();
    // getIt<ClipboardListener>().streamController.stream.listen((event) {
    //   showCustomSnackbar(
    //     context: context,
    //     contentText: 'Address found in clipboard.',
    //     actionText: 'Use',
    //     onPressed: () => getIt<ActionTriggerService>()
    //         .trigger(ActionStream(context: context, link: event)),
    //     second: 5, // default value 4 second
    //   );
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionListenerCubit,
            TransactionListenerCubitState>(
        bloc: BlocProvider.of<TransactionListenerCubit>(context),
        listener: (BuildContext context, state) async {
          if (state.address != null) {
            getIt<ActionTriggerService>().trigger(
                ActionStream(context: context, link: state.address.toString()));
          }
        },
        child: MessageHandler(
            child: IncomingTransactionHandler(child: widget.child)));
  }
}
