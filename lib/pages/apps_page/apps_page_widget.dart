import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_widgets.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';
import 'package:wlanpi_mobile/widgets/not_connected_overlay.dart';

import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:wlanpi_mobile/widgets/webview_widget.dart';

class AppsPageWidget extends StatefulWidget {
  const AppsPageWidget({super.key});

  @override
  State<AppsPageWidget> createState() => _AppsPageWidgetState();
}

class _AppsPageWidgetState extends State<AppsPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  SharedMethodsProvider? _sharedMethodsProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sharedMethodsProvider =
          Provider.of<SharedMethodsProvider>(context, listen: false);
      if (_sharedMethodsProvider!.connected) {
        _sharedMethodsProvider?.startStatsTimer();
        _sharedMethodsProvider?.bindWebView();
      }
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (_sharedMethodsProvider!.connected) {
        _sharedMethodsProvider?.stopStatsTimer();
      }
    });
    super.dispose();
  }

  void _openWebView(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text("Apps", style: theme.titleLarge),
      ),
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Kismet Container
                  _buildAppCard(
                    context,
                    "Kismet",
                    sharedMethods.kismetStatus,
                    "http://169.254.43.1:2501",
                    () {
                      sharedMethods.startStopService(
                          sharedMethods.kismetStatus["active"], "kismet");
                    },
                  ),
                  const SizedBox(height: 10.0),
                  // Grafana Container
                  _buildAppCard(
                    context,
                    "Grafana",
                    sharedMethods.grafanaStatus,
                    "https://169.254.43.1:3000",
                    () {
                      sharedMethods.startStopService(
                          sharedMethods.grafanaStatus["active"],
                          "grafana-server");
                    },
                  ),
                ],
              ),
            ),
            if (!sharedMethods.connected) const NotConnectedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(
    BuildContext context,
    String appName,
    Map<String, dynamic> status,
    String url,
    VoidCallback onToggleService,
  ) {
    final theme = CustomTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: theme.alternate, width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appName, style: theme.headlineSmall),
                Container(
                  decoration: BoxDecoration(
                      color: status["active"]
                          ? theme.accent2
                          : theme.error.withOpacity(0.36),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      status["active"] ? "Status: ON" : "Status: OFF",
                      style: theme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: onToggleService,
                      text: status["active"] ? "Stop" : "Start",
                      options: FFButtonOptions(
                        height: 40.0,
                        color: theme.primary,
                        textStyle: theme.titleSmall,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: status["active"]
                          ? () => _openWebView(appName, url)
                          : null,
                      text: "Open",
                      options: FFButtonOptions(
                        height: 40.0,
                        disabledTextColor: theme.infoText,
                        color: theme.alternate,
                        textStyle: theme.titleSmall,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
