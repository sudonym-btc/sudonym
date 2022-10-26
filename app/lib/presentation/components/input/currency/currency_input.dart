import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class CurrencyInput extends FormField<CurrencyInputOutput> {
  CurrencyInputOptions options;
  final void Function(CurrencyInputOutput)? onChanged;

  CurrencyInput({
    required this.options,
    this.onChanged,
    super.key,
  }) : super(
            builder: (FormFieldState<CurrencyInputOutput> state) =>
                (state as _CurrencyInputState)
                    .constructWidget(state.context, options));

  @override
  FormFieldState<CurrencyInputOutput> createState() => _CurrencyInputState();
}

class CurrencyInputOutput {
  num amount;
  String currency;
  CurrencyInputOutput(this.amount, this.currency);
}

class _CurrencyInputState extends FormFieldState<CurrencyInputOutput> {
  Widget constructWidget(BuildContext context, CurrencyInputOptions options) {
    return BlocProvider(
        create: (_) => CurrencyInputCubit(options),
        child: BlocBuilder<CurrencyInputCubit, CurrencyInputCubitState>(
          builder: (context, state) {
            List<MaterialState> negativeButtonState =
                state.negativeEnabled && !state.minLoading
                    ? []
                    : [MaterialState.disabled];
            List<MaterialState> positiveButtonState =
                state.positiveEnabled && !state.maxLoading
                    ? []
                    : [MaterialState.disabled];

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
                      .resolve(Set.of(negativeButtonState)),
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
                      .resolve(Set.of(positiveButtonState)),
                  icon: const Icon(Icons.add),
                ));

            return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.displayLarge,
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixText:
                              '${getCurrencySymbol(options.currencies[state.currCurrency])}  ',
                          prefixStyle: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color!
                                      .withAlpha(70)),
                          suffixIcon: IconButton(
                            iconSize: 24,
                            onPressed:
                                BlocProvider.of<CurrencyInputCubit>(context)
                                    .toggleCurrency,
                            icon: Icon(
                              Icons.swap_vert,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          helperText: state.altLoading
                              ? '...'
                              : FormatCurrency().format(
                                  options.currencies[state.altCurrency],
                                  state.altVal)),
                      controller: BlocProvider.of<CurrencyInputCubit>(context)
                          .controller,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(
                    width: padding / 2,
                  ),
                  negativeButton,
                  const SizedBox(
                    width: padding / 2,
                  ),
                  positiveButton
                ]);
          },
        ));
  }
}
