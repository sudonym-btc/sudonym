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
  final CurrencyInputOptions? options;
  final CurrencyInputCubit? cubit;
  final FormGroup? form;
  final void Function(CurrencyInputOutput)? onChanged;
  final bool large;

  CurrencyInput({
    this.options,
    this.large = false,
    this.cubit,
    this.form,
    this.onChanged,
    super.key,
  }) : super(
            builder: (FormFieldState<CurrencyInputOutput> state) =>
                BlocProvider(
                    // dispose: false,
                    create: (_) {
                      CurrencyInputCubit c =
                          cubit ?? CurrencyInputCubit(options!);
                      if (form != null) {
                        c.options.controller!.outputStream.stream
                            .listen((event) {
                          form.control('amount').updateValue(event);
                          form.control('amount').markAsDirty();
                        });
                      }

                      return c;
                    },
                    child: (state as _CurrencyInputState).constructWidget(
                        state.context, form, cubit, options, large)));

  @override
  FormFieldState<CurrencyInputOutput> createState() => _CurrencyInputState();
}

class CurrencyInputOutput extends Equatable {
  String? id;
  num amount;
  String currency;
  CurrencyInputOutput(this.amount, this.currency) {
    amount = num.parse(amount.toStringAsFixed(8));
  }

  @override
  List<Object?> get props => [amount, currency];
}

class _CurrencyInputState extends FormFieldState<CurrencyInputOutput> {
  Widget constructWidget(BuildContext context, FormGroup? form,
      CurrencyInputCubit? cubit, CurrencyInputOptions? options, bool large) {
    return BlocBuilder<CurrencyInputCubit, CurrencyInputCubitState>(
      builder: (context, state) {
        if (form != null) {
          if (state.error != null) {
            form.control('amount').setErrors({'amount': state.error});
          } else {
            form.control('amount').removeError('amount');
          }
        }
        Material negativeButton = Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: Ink(
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
                )));
        Material positiveButton = Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: Ink(
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
                )));

        Widget input = Column(
            crossAxisAlignment:
                large ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                enabled: state.options.enabled,
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
                  helperText: BlocProvider.of<CurrencyInputCubit>(context)
                          .options
                          .showAltCurrency
                      ? (state.altLoading
                          ? '...'
                          : FormatCurrency().format(
                              BlocProvider.of<CurrencyInputCubit>(context)
                                  .options
                                  .currencies[state.altCurrency],
                              state.altVal))
                      : '',
                  prefixText:
                      '${getCurrencySymbol(BlocProvider.of<CurrencyInputCubit>(context).options.currencies[state.currCurrency])}  ',
                  prefixStyle: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .color!
                              .withAlpha(70)),
                  suffixIcon: BlocProvider.of<CurrencyInputCubit>(context)
                          .options
                          .canSwitchCurrency
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
    );
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
