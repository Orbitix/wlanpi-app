import '/flutter_flow/flutter_flow_util.dart';
import 'usb_connection_widget.dart' show USBConnectionWidget;
import 'package:flutter/material.dart';

class USBConnectionModel extends FlutterFlowModel<USBConnectionWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
