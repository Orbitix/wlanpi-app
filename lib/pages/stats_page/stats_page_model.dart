import '../../utils/flutter_flow_util.dart';
// import '/actions/index.dart' as actions;
import 'stats_page_widget.dart' show StatsPageWidget;
import 'package:flutter/material.dart';

class StatsPageModel extends FlutterFlowModel<StatsPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
