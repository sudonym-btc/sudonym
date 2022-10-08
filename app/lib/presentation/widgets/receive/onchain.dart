import 'package:flutter/material.dart';
import 'receive_widget.dart';

class ReceiveOnchain extends ReceiveWidget {
  const ReceiveOnchain({required potId, Key? key})
      : super(potId: potId, type: 'onchain', key: key);
}
