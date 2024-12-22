import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/pages/tab_pages/stats_graph.dart';
import 'package:wlanpi_mobile/shared_methods.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class StatsPageWidget extends StatefulWidget {
  const StatsPageWidget({super.key});

  @override
  State<StatsPageWidget> createState() => _StatsPageWidgetState();
}

class _StatsPageWidgetState extends State<StatsPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: theme.alternate, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Container(
                                  child: Text(
                                    'Stats',
                                  ),
                                ),
                                StatsGraph(
                                  cpuHistory: sharedMethods.cpuHistory,
                                  cpuTempHistory: sharedMethods.cpuTempHistory,
                                  ramHistory: sharedMethods.ramHistory,
                                  diskHistory: sharedMethods.diskHistory,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 10.0)),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
