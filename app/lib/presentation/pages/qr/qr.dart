import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class QRPage extends StatefulWidget {
  final Pot? pot;

  QRPage(this.pot, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QRPageState();
  }
}

class _QRPageState extends State<QRPage> {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    controller.barcodes.listen((barcode) {
      final String? code = barcode.rawValue;
      getIt<ActionTriggerService>().trigger(
          ActionStream(context: context, link: code!, pot: widget.pot));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Stack(children: [
          MobileScanner(
              controller: controller,
              allowDuplicates: false,
              onDetect: (barcode, args) {}),
          SafeArea(
              child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                  ),
                  backgroundColor: Colors.transparent,
                  body: CustomPadding(
                      multiplier: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              color: Colors.white,
                              onPressed: () async {
                                XFile? image = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                print(image);
                                if (image != null) {
                                  if (!await controller
                                      .analyzeImage(image.path)) {
                                    SnackBar snackBar = SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .noQRFound),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    print("QR");
                                  }
                                }
                              },
                              icon: FaIcon(FontAwesomeIcons.photoFilm))
                        ],
                      ))))
        ]));
  }
}
