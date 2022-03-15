import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/bloc/receive.cubit.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';

import '../../../injection.dart';

class SendReceive extends StatelessWidget {
  final num potId;
  const SendReceive({required this.potId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ReceiveCubit cubit = getIt<ReceiveCubit>();
    cubit.getInvoice(potId, "bolt12", 0);

    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => cubit)],
        child: BlocBuilder<ReceiveCubit, ReceiveCubitState>(
            builder: (BuildContext context, state) {
          Widget image = QrImage(
            data: "lnbc507410n1p3z5cxkpp57374p4cd60uumn5jasj6sjtyw70p9g9gsz0skgxjftg8se688r0qdqqcqzpuxqyz5vqsp522wz0q6xsvk6wgm9vtgx90ud494gnlszq06at0dztznv0227p2lq9qyyssqrzulnuyy7ylc690yzehdmfk92qfspvy9w8qyxaq3rhypwmry87k4p8umxsvh0nzvund9erwdzzfz3zh5498e8vjn6u2auhn3q8ydpqgqcacjm4",
            version: QrVersions.auto,
            embeddedImage: NetworkImage(
                'https://www.kindpng.com/picc/m/73-733879_lightning-bolt-emoji-png-electricity-emoji-transparent-png.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(40, 40),
            ),
          );
          // Image(
          if (state.loading) {
            image = CircularProgressIndicator();
          }
          return FractionallySizedBox(
              widthFactor: 0.7,
              // padding: const EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Column contents vertically,
                crossAxisAlignment: CrossAxisAlignment
                    .center, //Center Column contents horizontally,
                children: [
                  image,
                  SizedBox(height: padding),
                  ButtonBar(
                    children: [
                      ElevatedButton.icon(
                        label: Text('Receive'),
                        style: raisedButtonStyle,
                        icon: FaIcon(FontAwesomeIcons.inbox, size: 14),
                        onPressed: () {
                          Navigator.pushNamed(context, '/receive', arguments: ReceivePageArgs(potId));
                        },
                      ),
                      ElevatedButton.icon(
                        label: Text('Send'),
                        style: raisedButtonStyle,
                        icon: FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                        onPressed: () {
                          Navigator.pushNamed(context, '/send');
                        },
                      )
                    ],
                  ),
                ],
              ));
        }));
  }
}
