import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class CurrencyInput extends FormField<CurrencyInputOutput> {
  final CurrencyInputOptions options;
  final void Function(CurrencyInputOutput)? onChanged;
  final bool large;

  CurrencyInput({
    required this.options,
    this.large = false,
    this.onChanged,
    super.key,
  }) : super(
            builder: (FormFieldState<CurrencyInputOutput> state) =>
                (state as _CurrencyInputState)
                    .constructWidget(state.context, options, large));

  @override
  FormFieldState<CurrencyInputOutput> createState() => _CurrencyInputState();
}

class CurrencyInputOutput {
  num amount;
  String currency;
  CurrencyInputOutput(this.amount, this.currency);
}

class _CurrencyInputState extends FormFieldState<CurrencyInputOutput> {
  Widget constructWidget(
      BuildContext context, CurrencyInputOptions options, bool large) {
    return BlocProvider(
        create: (_) => CurrencyInputCubit(options),
        child: BlocBuilder<CurrencyInputCubit, CurrencyInputCubitState>(
          builder: (context, state) {
            Ink negativeButton = Ink(
                decoration: buttonDecoration(context, state.negativeEnabled),
                child: IconButton(
                  onPressed: state.negativeEnabled
                      ? () => BlocProvider.of<CurrencyInputCubit>(context)
                          .decrementValue()
                      : null,
                  color: Theme.of(context)
                      .elevatedButtonTheme
                      .style!
                      .foregroundColor!
                      .resolve({}),
                  icon: const Icon(Icons.remove),
                ));
            Ink positiveButton = Ink(
                decoration: buttonDecoration(context, state.positiveEnabled),
                child: IconButton(
                  onPressed: state.positiveEnabled
                      ? () => BlocProvider.of<CurrencyInputCubit>(context)
                          .incrementValue()
                      : null,
                  color: Theme.of(context)
                      .elevatedButtonTheme
                      .style!
                      .foregroundColor!
                      .resolve({}),
                  icon: const Icon(Icons.add),
                ));

            Widget input = Column(
                crossAxisAlignment: large
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: large ? TextAlign.center : TextAlign.start,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        // fontSize: 44,
                        ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixText:
                          '${getCurrencySymbol(options.currencies[state.currCurrency])}  ',
                      prefixStyle: Theme.of(context)
                          .textTheme
                          .displayLarge!
                          .copyWith(
                              // fontSize: 44,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color!
                                  .withAlpha(70)),
                      suffixIcon: IconButton(
                        iconSize: 24,
                        onPressed: BlocProvider.of<CurrencyInputCubit>(context)
                            .toggleCurrency,
                        icon: Icon(
                          Icons.swap_vert,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    controller:
                        BlocProvider.of<CurrencyInputCubit>(context).controller,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  Info(state.altLoading
                      ? '...'
                      : FormatCurrency().format(
                          options.currencies[state.altCurrency], state.altVal)),
                  const SizedBox(
                    height: padding,
                  ),
                ]);
            if (large) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  input,
                  const SizedBox(
                    height: padding * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      negativeButton,
                      const SizedBox(
                        width: padding * 2,
                      ),
                      positiveButton
                    ],
                  )
                ],
              );
            }

            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: input,
                        ),
                        const SizedBox(
                          width: padding / 2,
                        ),
                        negativeButton,
                        const SizedBox(
                          width: padding / 2,
                        ),
                        positiveButton
                      ])
                ]);
          },
        ));
  }
}
