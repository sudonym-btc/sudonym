import 'package:flutter/material.dart' hide ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/logic/bloc/contact.cubit.dart';
import 'package:sudonym/presentation/widgets/contacts/contact_list.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:sudonym/presentation/widgets/send/qr.dart';

import '../../constants.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

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
    );

    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Send'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    tooltip: 'Scan QR code',
                    onPressed: () {
                      setState(() {
                        toggleCam();
                      });
                    },
                  ),
                ],
              ),
              body: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        curve: Curves.easeInOut,
                        duration: animationDuration,
                        child: LimitedBox(
                            maxHeight: camOpen ? 200 : 0, child: QRView()),
                      ),
                      const SizedBox(height: padding),
                      invoiceInput,
                      const SizedBox(height: padding),
                      Expanded(
                        child: ContactList(),
                      ),
                      const SizedBox(height: padding),
                      ButtonBar(children: [
                        ElevatedButton.icon(
                          label: Text('Send'),
                          style: raisedButtonStyle,
                          icon: FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                          onPressed: () {
                            Navigator.pushNamed(context, '/confirmSend',
                                arguments: {"address": controller.value.text});
                          },
                        )
                      ])
                    ],
                  ))),
        ));
  }
}

class _InvoiceInput extends StatefulWidget {
  TextEditingController? controller;
  _InvoiceInput({this.controller}) : super() {
    controller ??= TextEditingController();
  }
  @override
  State<StatefulWidget> createState() {
    return _InvoiceInputState(controller!);
  }
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
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        // border: OutlineInputBorder(),
        hintText: 'Lightning address',
      ),
      focusNode: _focus,
    );
  }
}
