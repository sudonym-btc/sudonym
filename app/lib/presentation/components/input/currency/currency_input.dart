import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class CurrencyInput extends FormField<CurrencyInputOutput> {
  final CurrencyInputOptions options;
  final FormGroup? form;
  final void Function(CurrencyInputOutput)? onChanged;
  final bool large;

  CurrencyInput({
    required this.options,
    this.large = false,
    this.form,
    this.onChanged,
    super.key,
  }) : super(
            builder: (FormFieldState<CurrencyInputOutput> state) =>
                (state as _CurrencyInputState)
                    .constructWidget(state.context, form, options, large));

  @override
  FormFieldState<CurrencyInputOutput> createState() => _CurrencyInputState();
}

class CurrencyInputOutput extends Equatable {
  num amount;
  String currency;
  CurrencyInputOutput(this.amount, this.currency);

  @override
  List<Object?> get props => [amount, currency];
}

class _CurrencyInputState extends FormFieldState<CurrencyInputOutput> {
  Widget constructWidget(BuildContext context, FormGroup? form,
      CurrencyInputOptions options, bool large) {
    return BlocProvider(create: (_) {
      CurrencyInputCubit c = CurrencyInputCubit(options);
      if (form != null) {
        form.control('amount').valueChanges.listen((event) {
          c.controller!.updateValue(event!.amount);
          c.setValue(event!.amount);
        });
        c.options.controller!.outputStream.stream.listen((event) {
          form.control('amount').updateValue(event);
        });
      }

      return c;
    }, child: BlocBuilder<CurrencyInputCubit, CurrencyInputCubitState>(
      builder: (context, state) {
        if (form != null) {
          if (state.error != null) {
            form.control('amount').setErrors({'amount': state.error});
          } else {
            form.control('amount').removeError('amount');
          }
        }
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
              icon: const Icon(Icons.remove, size: iconSize * 1.5),
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
              icon: const Icon(Icons.add, size: iconSize * 1.5),
            ));

        Widget input = Column(
            crossAxisAlignment:
                large ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                  errorText: formatError(context, state.error),
                  helperText: options.showAltCurrency
                      ? (state.altLoading
                          ? '...'
                          : FormatCurrency().format(
                              options.currencies[state.altCurrency],
                              state.altVal))
                      : '',
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
                  suffixIcon: options.canSwitchCurrency
                      ? IconButton(
                          iconSize: iconSize * 1.5,
                          onPressed:
                              BlocProvider.of<CurrencyInputCubit>(context)
                                  .toggleCurrency,
                          icon: Icon(
                            Icons.swap_vert,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : null,
                ),
                controller:
                    BlocProvider.of<CurrencyInputCubit>(context).controller,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
              // const VertDivider(),
            ]);
        if (large) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              input,
              const VertDivider(2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  negativeButton,
                  const HoriDivider(2),
                  positiveButton
                ],
              )
            ],
          );
        }

        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(
              child: input,
            ),
            const HoriDivider(0.5),
            negativeButton,
            const HoriDivider(0.5),
            positiveButton
          ])
        ]);
      },
    ));
  }
}

formatError(BuildContext context, Map<String, dynamic>? error) {
  if (error == null) return null;
  if (error['min'] != null) {
    return AppLocalizations.of(context)!.minAmount(error['min']);
  }
  if (error['max'] != null) {
    return AppLocalizations.of(context)!.maxAmount(error['max']);
  }
}
