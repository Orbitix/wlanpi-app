import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';
import 'package:wlanpi_mobile/widgets/not_connected_overlay.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '../../theme/theme.dart';
import '../../utils/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppsPageWidget extends StatefulWidget {
  const AppsPageWidget({super.key});

  @override
  State<AppsPageWidget> createState() => _AppsPageWidgetState();
}

class _AppsPageWidgetState extends State<AppsPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  SharedMethodsProvider? _sharedMethodsProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sharedMethodsProvider =
          Provider.of<SharedMethodsProvider>(context, listen: false);
      if (_sharedMethodsProvider!.connected) {
        _sharedMethodsProvider?.startStatsTimer();
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

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: true,
        title: Text("Apps", style: theme.titleLarge),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: theme.alternate, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kismet',
                              style: theme.headlineSmall.override(
                                fontFamily: theme.headlineSmallFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    CustomTheme.of(context)
                                        .headlineSmallFamily),
                              ),
                            ),
                            Text(
                              sharedMethods.kismetStatus["active"]
                                  ? "Status: ON"
                                  : "Status: OFF",
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    CustomTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            10.0, 0.0, 10.0, 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FFButtonWidget(
                              onPressed: () {
                                sharedMethods.kismetStatus =
                                    sharedMethods.startStopService(
                                        sharedMethods.kismetStatus["active"],
                                        "kismet") as Map<String, dynamic>;
                                setState(() {});
                              },
                              text: sharedMethods.kismetStatus["active"]
                                  ? "Stop"
                                  : "Start",
                              options: FFButtonOptions(
                                height: 30.0,
                                padding: const EdgeInsets.all(0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: theme.primary,
                                textStyle: CustomTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: theme.bodyLargeFamily,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(CustomTheme.of(context)
                                              .bodyLargeFamily),
                                    ),
                                elevation: 0.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            Text(
                              'URL: http://wlanpi-bc2.local:2005',
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    CustomTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: theme.alternate, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grafana',
                              style: theme.headlineSmall.override(
                                fontFamily: theme.headlineSmallFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    CustomTheme.of(context)
                                        .headlineSmallFamily),
                              ),
                            ),
                            Text(
                              sharedMethods.grafanaStatus["active"]
                                  ? "Status: ON"
                                  : "Status: OFF",
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    CustomTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            10.0, 0.0, 10.0, 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FFButtonWidget(
                              onPressed: () {
                                sharedMethods.startStopService(
                                    sharedMethods.grafanaStatus["active"],
                                    "grafana-server");
                              },
                              text: sharedMethods.grafanaStatus["active"]
                                  ? "Stop"
                                  : "Start",
                              options: FFButtonOptions(
                                height: 30.0,
                                padding: const EdgeInsets.all(0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: theme.primary,
                                textStyle: CustomTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: theme.bodyLargeFamily,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(CustomTheme.of(context)
                                              .bodyLargeFamily),
                                    ),
                                elevation: 0.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            Text(
                              'URL: http://wlanpi-bc2.local:2005',
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    CustomTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ].divide(const SizedBox(height: 10.0)),
            ),
          ),
          if (!sharedMethods.connected) NotConnectedOverlay()
        ]),
      ),
    );
  }
}
