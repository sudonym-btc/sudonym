import 'package:flutter/material.dart' hide ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/pages/qr/qr.dart';
// import 'package:sudonym/presentation/widgets/contacts/contact_list.dart';
// import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
// import 'package:sudonym/presentation/widgets/send/qr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../logic/bloc/link.service.dart';

class SendPage extends StatefulWidget {
  final dynamic potId;

  const SendPage({this.potId, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SendPageState();
  }
}

class _SendPageState extends State<SendPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  TextEditingController controller = TextEditingController();
  bool camOpen = false;

  toggleCam() {
    camOpen = !camOpen;
  }

  @override
  Widget build(BuildContext context) {
    _InvoiceInput invoiceInput = _InvoiceInput(
      controller: controller,
      onPressed: () {
        getIt<LinkService>()
            .trigger(controller.value.text, context, widget.potId);
      },
    );

    return Container(
        color: Theme.of(context).colorScheme.background,
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
                                builder: (context) => QRPage(widget.potId)));
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
                      invoiceInput,
                      const SizedBox(height: padding)
                    ],
                  ))),
        ));
  }
}

class _InvoiceInput extends StatefulWidget {
  TextEditingController? controller;
  Function()? onPressed;
  _InvoiceInput({this.controller, this.onPressed}) : super() {
    controller ??= TextEditingController();
  }
  @override
  State<StatefulWidget> createState() => _InvoiceInputState(controller!);
}

class _InvoiceInputState extends State<_InvoiceInput> {
  FocusNode _focus = FocusNode();
  TextEditingController _controller;

  _InvoiceInputState(this._controller) : super() {
    _focus.addListener(_onFocusChange);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    // debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          keyboardType: TextInputType.emailAddress,
          controller: _controller,
          decoration: InputDecoration(
              // border: OutlineInputBorder(),
              hintText: (AppLocalizations.of(context)!.lightningAddress)),
          focusNode: _focus,
        )),
        Button(
          onPressed: widget.onPressed,
          text: "OK",
        )
      ],
    );
  }
}
