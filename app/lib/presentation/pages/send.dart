import 'package:flutter/material.dart' hide ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/logic/bloc/contact.cubit.dart';
import 'package:sudonym/presentation/components/button/button.dart';
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
      onPressed: () {
        Navigator.pushNamed(context, '/confirmSend',
            arguments: {"address": controller.value.text});
      },
    );

    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Send'),
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
                            maxHeight: camOpen ? 1000 : 200, child: QRView()),
                      ),
                      const SizedBox(height: padding),
                      invoiceInput,
                      const SizedBox(height: padding),
                      Expanded(
                        child: ContactList(),
                      ),
                      // const SizedBox(height: padding),
                      // ButtonBar(children: [
                      //   Button(
                      //     text: 'Send',
                      //     icon: FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                      //     onPressed: () {
                      //       Navigator.pushNamed(context, '/confirmSend',
                      //           arguments: {"address": controller.value.text});
                      //     },
                      //   )
                      // ])
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
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            // border: OutlineInputBorder(),
            hintText: 'Lightning address',
          ),
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
