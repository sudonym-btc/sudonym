import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

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
    super.initState();

    listCubit = ListCubit(getIt<ContactRepository>());
    form
        .control('address')
        .valueChanges
        .debounceTime(const Duration(milliseconds: 1000))
        .listen((event) {
      listCubit.setWhere(event.isNotEmpty
          ? {
              'name': {'like': '%$event%'}
            }
          : {});
      listCubit.reset();
      listCubit.loadNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
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
                  icon: const FaIcon(Icons.camera_alt))
            ],
          ),
          body: SafeArea(
              child: CustomPadding(
                  multiplier: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: padding),
                      ReactiveForm(
                          formGroup: form,
                          child: ReactiveTextField(
                              formControlName: 'address',
                              onEditingComplete: null,
                              autocorrect: false,
                              onSubmitted: form.valid
                                  ? (control) => getIt<ActionTriggerService>()
                                      .trigger(ActionStream(
                                          context: context,
                                          link: form.control('address').value,
                                          pot: widget.pot))
                                  : null,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  suffixIcon: ReactiveFormConsumer(
                                    builder: (context, form, child) {
                                      return IconButton(
                                        icon: const Icon(Icons.arrow_forward),
                                        iconSize: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .fontSize,
                                        color: Theme.of(context).primaryColor,
                                        onPressed: form.valid
                                            ? () =>
                                                getIt<ActionTriggerService>()
                                                    .trigger(ActionStream(
                                                        context: context,
                                                        link: form
                                                            .control('address')
                                                            .value,
                                                        pot: widget.pot))
                                            : null,
                                        // text: 'OK',
                                      );
                                    },
                                  ),
                                  hintText: AppLocalizations.of(context)!
                                      .addressInputHint,
                                  labelText:
                                      AppLocalizations.of(context)!.address))),

                      const VertDivider(2),
                      CheckClipboard(
                        pot: widget.pot,
                      ),
                      CreateRedeem(
                        pot: widget.pot,
                      ),
                      const VertDivider(),
                      Expanded(
                          child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Subheader(AppLocalizations.of(context)!.contacts),
                              IconButton(
                                  iconSize: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .fontSize,
                                  icon: const FaIcon(FontAwesomeIcons.plus),
                                  // text: AppLocalizations.of(context)!.add,
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditContactPage(
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

class CreateRedeem extends StatelessWidget {
  final Pot pot;
  const CreateRedeem({required this.pot, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FaIcon(
              FontAwesomeIcons.gift,
              size: iconSize,
            ),
          ],
        ),
        title: Text(
          AppLocalizations.of(context)!.createRedeem,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AmountPage<Payment>(
                text: AppLocalizations.of(context)!.create,
                options: CurrencyInputOptions(
                    initialValue: CurrencyInputOutput(
                        pot.currency == 'BTC' ? 1 / SATOSHIS : 0.01,
                        pot.currency),
                    min: [
                      CurrencyInputOutput(1 / SATOSHIS, 'BTC'),
                    ],
                    max: [
                      CurrencyInputOutput(pot.spendableBalance, pot.currency)
                    ]),
                onDone: (output) async {
                  Sender sender = await getIt<SenderRepository>().create({
                    'potId': pot.id,
                    'type': 'lnurl',
                    'limitMax': output.amount,
                    'amountCurrency': output.currency
                  });
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => SenderPage(entity: sender)),
                      (route) => route.isFirst);
                }))));
  }
}

class CheckClipboard extends StatefulWidget {
  final Pot? pot;
  const CheckClipboard({this.pot, super.key});

  @override
  State<StatefulWidget> createState() => CheckClipboardState();
}

class CheckClipboardState extends State<CheckClipboard> {
  String? address;
  bool hasChecked = false;

  @override
  void initState() {
    super.initState();

    if (getIt<ClipboardListener>().canReadClipboardUndetected()) {
      getIt<ClipboardListener>()
          .check()
          .then((value) => setState((() => address = value)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (getIt<ClipboardListener>().canReadClipboardUndetected()) {
      if (address != null) {
        return ListTile(
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  FaIcon(
                    FontAwesomeIcons.paste,
                    size: iconSize,
                  )
                ]),
            title: Text(
              '${AppLocalizations.of(context)!.paste} "$address"',
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onTap: () => getIt<ActionTriggerService>().trigger(ActionStream(
                context: context, link: address!, pot: widget.pot)));
      }
      return Container();
    }
    return ListTile(
      leading:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        FaIcon(
          FontAwesomeIcons.paste,
          size: iconSize,
        )
      ]),
      title: Text(AppLocalizations.of(context)!.checkClipboard),
      onTap: () => getIt<ClipboardListener>().check().then((value) {
        setState(() {
          hasChecked = true;
        });
        if (value != null) {
          address = value;
          getIt<ActionTriggerService>().trigger(
              ActionStream(context: context, link: value, pot: widget.pot));
        }
      }),
      isThreeLine: false,
      subtitle: hasChecked && address == null
          ? Text(AppLocalizations.of(context)!.noAddressToPaste)
          : null,
    );
  }
}
