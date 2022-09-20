import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/bloc/entity_cubit_state.dart';
import 'package:sudonym/presentation/components/button/button.dart';

class CustomForm<T extends BaseClass> extends StatefulWidget {
  final T entity;
  final EntityCubit<EntityCubitState<T>, T> cubit;
  final List<Widget> children;
  final Function? onSave;

  const CustomForm(
      {required this.entity,
      required this.cubit,
      required this.children,
      this.onSave,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    widget.cubit.set(widget.entity);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ...widget.children.map((e) => Column(
                    children: [
                      const SizedBox(height: padding),
                      e,
                      const SizedBox(height: padding)
                    ],
                  )),
              Expanded(child: Container()),
              Button(
                onPressed: () async {
                  _formKey.currentState?.save();

                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    try {
                      final formData = _formKey.currentState?.value;
                      Map<String, dynamic> d =
                          ({...widget.entity.toJson(), ...formData!});
                      await widget.cubit
                          .createOrUpdate(widget.cubit.repository.converter(d));
                      if (widget.onSave != null) widget.onSave!();
                    } catch (e) {
                      rethrow;
                    }
                  }
                },
                text: 'Submit',
              ),
            ]));
  }
}
