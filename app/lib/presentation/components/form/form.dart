import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class CustomForm<
    C extends EntityCubit<CrudRepository<T>, CS, T>,
    CS extends EntityCubitState<T>,
    T extends BaseClass> extends StatefulWidget {
  final T entity;
  final FormGroup Function() formGroup;
  final dynamic Function(BuildContext context, dynamic state) builder;
  final Function(Map<String, dynamic> formData)? beforeSave;
  final Future<dynamic> Function(dynamic entity)? onSave;
  final bool hideSubmit;

  const CustomForm(
      {required this.entity,
      required this.formGroup,
      required this.builder,
      this.beforeSave,
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
    T extends BaseClass> extends State<CustomForm> with FormLogger {
  late FormGroup formGroup;
  bool loading = false;

  @override
  void initState() {
    formGroup = widget.formGroup();
    super.initState();
  }

  submit(BuildContext context, FormGroup form) async {
    setState(() {
      loading = true;
    });
    // Validate returns true if the form is valid, or false otherwise.
    try {
      final formData = widget.beforeSave != null
          ? widget.beforeSave!(form.value)
          : form.value;
      Map<String, dynamic> d = {...widget.entity.toJson(), ...formData};
      T t = await BlocProvider.of<C>(context)
          .createOrUpdate(BlocProvider.of<C>(context).repository.converter(d));
      formGroup.markAsPristine();
      if (widget.onSave != null) {
        widget.onSave!(t);
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 400) {
        loggy.e(e.response?.data?['message']);
        for (final obj in e.response?.data?['message']) {
          if (obj is String) {
            form.setErrors({'main': obj});
          } else {
            form.control(obj['property']).setErrors(obj['message'] != null
                ? {obj['message']: true}
                : obj['constraints']);
          }
        }
        form.markAllAsTouched();
      } else {
        rethrow;
      }
    }

    setState(() {
      loading = false;
    });
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
                    const VertDivider(),
                    ReactiveFormConsumer(
                      builder: (context, form, child) {
                        return form.dirty || !widget.hideSubmit
                            ? Button(
                                onPressed: form.valid && form.dirty && !loading
                                    ? () => submit(context, form)
                                    : null,
                                icon: loading
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator())
                                    : null,
                                text: loading
                                    ? null
                                    : AppLocalizations.of(context)!.submit,
                              )
                            : Container();
                      },
                    ),
                  ]));
        });
  }
}
