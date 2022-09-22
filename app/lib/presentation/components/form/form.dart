import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

class CustomForm<Repo extends CrudRepository, T extends BaseClass>
    extends StatefulWidget {
  final T entity;
  final EntityCubit<Repo, EntityCubitState<T>, T> cubit;
  final List<Widget> children;
  final Function? onSave;
  final bool hideSubmit;

  const CustomForm(
      {required this.entity,
      required this.cubit,
      required this.children,
      this.onSave,
      this.hideSubmit = false,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool dirty = false;

  @override
  void initState() {
    widget.cubit.set(widget.entity);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_formKey.currentState != null) _formKey.currentState!.validate();
    var children = <Widget>[
      ...widget.children.map((e) => Column(
            children: [
              const SizedBox(height: padding),
              e,
              const SizedBox(height: padding)
            ],
          )),
      // Expanded(child: Container()),
    ];
    children.addAll(dirty || !widget.hideSubmit
        ? [
            Button(
              onPressed: _formKey.currentState != null &&
                      _formKey.currentState!.isValid
                  ? () async {
                      _formKey.currentState?.save();

                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        try {
                          final formData = _formKey.currentState?.value;
                          Map<String, dynamic> d =
                              ({...widget.entity.toJson(), ...formData!});
                          await widget.cubit.createOrUpdate(
                              widget.cubit.repository.converter(d));
                          if (widget.onSave != null) widget.onSave!();
                        } catch (e) {
                          rethrow;
                        }
                      }
                    }
                  : null,
              text: 'Submit',
            )
          ]
        : []);
    return FormBuilder(
        key: _formKey,
        onChanged: () {
          setState(() {
            dirty = getChangedValues(useInstantValues: true).isNotEmpty;
          });
        },
        autovalidateMode: AutovalidateMode.always,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children));
  }

  /// Get only the changed values.
  /// Compare the initial value and actual value of form and get the difference
  ///
  /// By default, use saved values [formValues] as actual value
  Map<String, dynamic> getChangedValues({bool useInstantValues = false}) {
    final _formValues = useInstantValues
        ? _formKey.currentState?.instantValue ?? {}
        : _formKey.currentState?.value ?? {};
    final _initialValues = _formKey.currentState?.initialValue ?? {};
    final _changedValues = <String, dynamic>{};

    for (var entry in _formValues.entries) {
      if (_formValues[entry.key] != _initialValues[entry.key]) {
        _changedValues[entry.key] = entry.value;
      }
    }

    print(_changedValues);

    return _changedValues;
  }
}
