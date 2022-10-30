import 'package:flutter/material.dart' hide ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

class SendPage extends StatefulWidget {
  final Pot pot;

  const SendPage({required this.pot, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SendPageState();
  }
}

class _SendPageState extends State<SendPage> {
  FormGroup form = FormGroup({
    'address': FormControl<String>(value: '', validators: [
      Validators.required,
      isValidAddressValidator,
    ]),
  });
  late ListCubit listCubit;

  @override
  void initState() {
    listCubit = ListCubit(getIt<ContactRepository>());
    form
        .control('address')
        .valueChanges
        .debounceTime(const Duration(milliseconds: 500))
        .listen((event) {
      listCubit.setWhere(event.isNotEmpty
          ? {
              'name': {'like': event}
            }
          : {});
      listCubit.reset();
      listCubit.loadNext();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Send'),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QRPage(widget.pot)));
                      },
                      icon: const FaIcon(FontAwesomeIcons.camera))
                ],
              ),
              body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: padding),
                      ReactiveForm(
                        formGroup: form,
                        child: Row(children: [
                          Expanded(
                              child: ReactiveTextField(
                                  formControlName: 'address',
                                  onEditingComplete: null,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      hintText: 'Lightning address, invoice...',
                                      labelText: AppLocalizations.of(context)!
                                          .address))),
                          ReactiveFormConsumer(
                            builder: (context, form, child) {
                              return Button(
                                onPressed: form.valid
                                    ? () => getIt<ActionTriggerService>()
                                        .trigger(form.control('address').value,
                                            context, widget.pot)
                                    : null,
                                text: 'OK',
                              );
                            },
                          ),
                        ]),
                      ),
                      const SizedBox(height: padding * 2),
                      Expanded(
                          child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Header('Contacts'),
                              Button(
                                  text: 'Add',
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditContact(
                                                  entity: Contact.fromJson({
                                                'ContactAddresses': [
                                                  {'address': ''}
                                                ]
                                              })))))
                            ]),
                        Expanded(
                            child: ListWidget(
                          emptyText: 'No contacts',
                          list: () => listCubit,
                          builder: (el) {
                            return ContactListItem(
                                contact: el,
                                onPressed: () => getIt<ActionTriggerService>()
                                    .trigger(el.ContactAddresses[0].address,
                                        context, widget.pot));
                          },
                        ))
                      ]))
                    ],
                  ))),
        ));
  }
}
