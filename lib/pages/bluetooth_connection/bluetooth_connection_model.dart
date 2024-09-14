import '/flutter_flow/flutter_flow_util.dart';
import 'bluetooth_connection_widget.dart' show BluetoothConnectionWidget;
import 'package:flutter/material.dart';

class BluetoothConnectionModel
    extends FlutterFlowModel<BluetoothConnectionWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
