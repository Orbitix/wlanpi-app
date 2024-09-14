import '/flutter_flow/flutter_flow_util.dart';
import 'wi_fi_connection_widget.dart' show WiFiConnectionWidget;
import 'package:flutter/material.dart';

class WiFiConnectionModel extends FlutterFlowModel<WiFiConnectionWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
