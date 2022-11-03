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
                title: Text(AppLocalizations.of(context)!.send),
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
                                      hintText: AppLocalizations.of(context)!
                                          .addressInputHint,
                                      labelText: AppLocalizations.of(context)!
                                          .address))),
                          ReactiveFormConsumer(
                            builder: (context, form, child) {
                              return Button(
                                onPressed: form.valid
                                    ? () => getIt<ActionTriggerService>()
                                        .trigger(ActionStream(
                                            context: context,
                                            link: form.control('address').value,
                                            pot: widget.pot))
                                    : null,
                                text: 'OK',
                              );
                            },
                          ),
                        ]),
                      ),
                      const SizedBox(height: padding * 2),
                      CheckClipboard(),
                      Expanded(
                          child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Header(AppLocalizations.of(context)!.contacts),
                              Button(
                                  text: AppLocalizations.of(context)!.add,
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
                          emptyText:
                              AppLocalizations.of(context)!.noContactsFound,
                          list: () => listCubit,
                          builder: (el) {
                            return ContactListItem(
                                contact: el,
                                onPressed: () => getIt<ActionTriggerService>()
                                    .trigger(ActionStream(
                                        context: context,
                                        link: el.ContactAddresses[0].address,
                                        pot: widget.pot)));
                          },
                        ))
                      ]))
                    ],
                  ))),
        ));
  }
}

class CheckClipboard extends StatelessWidget {
  final Pot? pot;
  const CheckClipboard({this.pot, super.key});

  @override
  Widget build(BuildContext context) {
    if (getIt<ClipboardListener>().canReadClipboardUndetected()) {
      return Container();
    }
    return Column(children: [
      ListTile(
        leading: Icon(Icons.paste),
        title: const Text('Check clipboard'),
        onTap: () => getIt<ClipboardListener>().check().then((value) {
          if (value != null) {
            print("trillolol");
            getIt<ActionTriggerService>()
                .trigger(ActionStream(context: context, link: value, pot: pot));
          }
        }),
      ),
      const SizedBox(height: padding * 2),
    ]);
  }
}
