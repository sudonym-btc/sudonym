import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomForm<
    C extends EntityCubit<CrudRepository<T>, CS, T>,
    CS extends EntityCubitState<T>,
    T extends BaseClass> extends StatefulWidget {
  final T entity;
  final FormGroup Function() formGroup;
  final dynamic Function(BuildContext context, dynamic state) builder;
  final Function? onSave;
  final bool hideSubmit;

  const CustomForm(
      {required this.entity,
      required this.formGroup,
      required this.builder,
      this.onSave,
      this.hideSubmit = false,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFormState<C, CS, T>();
}

class _CustomFormState<
    C extends EntityCubit<CrudRepository<T>, CS, T>,
    CS extends EntityCubitState<T>,
    T extends BaseClass> extends State<CustomForm> {
  late FormGroup formGroup;

  @override
  void initState() {
    formGroup = widget.formGroup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<C, CS, T>(
        entity: widget.entity as T,
        fetch: false,
        builder: (BuildContext context, CS state) {
          return ReactiveForm(
              formGroup: formGroup,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.builder(context, state),
                    const SizedBox(
                      height: padding,
                    ),
                    ReactiveFormConsumer(
                      builder: (context, form, child) {
                        return form.dirty || !widget.hideSubmit
                            ? Button(
                                onPressed: form.valid && form.dirty
                                    ? () async {
                                        // Validate returns true if the form is valid, or false otherwise.
                                        try {
                                          final formData = form.value;
                                          Map<String, dynamic> d = ({
                                            ...widget.entity.toJson(),
                                            ...formData
                                          });
                                          await BlocProvider.of<C>(context)
                                              .createOrUpdate(
                                                  BlocProvider.of<C>(context)
                                                      .repository
                                                      .converter(d));
                                          formGroup.markAsPristine();
                                          if (widget.onSave != null) {
                                            widget.onSave!();
                                          }
                                        } catch (e) {
                                          if (e is DioError &&
                                              e.response?.statusCode == 400) {
                                            for (final obj in e
                                                .response?.data?['message']) {
                                              form
                                                  .control(obj['property'])
                                                  .setErrors(
                                                      {obj['message']: true});
                                            }
                                            form.markAllAsTouched();
                                          } else {
                                            rethrow;
                                          }
                                        }
                                      }
                                    : null,
                                text: AppLocalizations.of(context)!.submit,
                              )
                            : Container();
                      },
                    ),
                  ]));
        });
  }
}
