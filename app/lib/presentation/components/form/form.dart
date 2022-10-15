import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class CustomForm<Repo extends CrudRepository<T>, T extends BaseClass>
    extends StatefulWidget {
  final T entity;
  final EntityCubit<Repo, EntityCubitState<T>, T> Function() cubit;
  final FormGroup Function() formGroup;
  final List<Widget> children;
  final Function? onSave;
  final bool hideSubmit;

  const CustomForm(
      {required this.entity,
      required this.cubit,
      required this.formGroup,
      required this.children,
      this.onSave,
      this.hideSubmit = false,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  late EntityCubit c;
  late FormGroup formGroup;

  @override
  void initState() {
    c = widget.cubit();
    c.set(widget.entity);
    formGroup = widget.formGroup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (_formKey.currentState != null) _formKey.currentState!.validate();
    var children = <Widget>[
      ...widget.children.map((e) => Column(
            children: [
              const SizedBox(height: padding),
              e,
              const SizedBox(height: padding)
            ],
          )),
    ];
    children.addAll([
      ReactiveFormConsumer(
        builder: (context, form, child) {
          return form.dirty || !widget.hideSubmit
              ? Button(
                  onPressed: form.valid
                      ? () async {
                          // Validate returns true if the form is valid, or false otherwise.
                          try {
                            final formData = form.value;
                            print(formData);
                            Map<String, dynamic> d =
                                ({...widget.entity.toJson(), ...formData});
                            await c.createOrUpdate(c.repository.converter(d));
                            if (widget.onSave != null) widget.onSave!();
                          } catch (e) {
                            rethrow;
                          }
                        }
                      : null,
                  text: 'Submit',
                )
              : Container();
        },
      ),
    ]);
    return ReactiveForm(
        formGroup: formGroup,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children));
  }
}
