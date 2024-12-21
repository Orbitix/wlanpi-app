import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/pages/tab_pages/app_page_widget.dart';
import 'package:wlanpi_mobile/pages/tab_pages/control_panel_page/control_panel_page_widget.dart';
import 'package:wlanpi_mobile/pages/tab_pages/stats_page_widget.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'device_page_model.dart';
export 'device_page_model.dart';

import 'package:wlanpi_mobile/shared_methods.dart';

class DevicePageWidget extends StatefulWidget {
  const DevicePageWidget({super.key});

  @override
  State<DevicePageWidget> createState() => _DevicePageWidgetState();
}

class _DevicePageWidgetState extends State<DevicePageWidget>
    with TickerProviderStateMixin {
  late DevicePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  SharedMethodsProvider? _sharedMethodsProvider;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DevicePageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sharedMethodsProvider =
          Provider.of<SharedMethodsProvider>(context, listen: false);
      _sharedMethodsProvider?.getInfo();
      _sharedMethodsProvider?.startStatsTimer();
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => setState(() {}));
    animationsMap.addAll({
      'imageOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
    Future.microtask(() {
      _sharedMethodsProvider?.stopStatsTimer();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: const AlignmentDirectional(-1.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/thumbnail_image002.png',
                height: 50.0,
                fit: BoxFit.contain,
                alignment: const Alignment(0.0, 0.0),
              ),
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation']!),
          ),
          actions: [
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Mobile',
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: GoogleFonts.asMap()
                        .containsKey(theme.titleMediumFamily),
                  ),
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topLeft: Radius.circular(0.0),
                      topRight: Radius.circular(0.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      height: 92.0,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: theme.alternate, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    sharedMethods.deviceInfo['name'].toString(),
                                    style: theme.labelLarge.override(
                                      fontFamily: theme.labelLargeFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(theme.labelLargeFamily),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.circle,
                                  color: theme.secondary,
                                  size: 16.0,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Model:\n${sharedMethods.deviceInfo['model']?.toString()}",
                                    style: theme.labelMedium.override(
                                      fontFamily: theme.labelMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(theme.labelMediumFamily),
                                    ),
                                  ),
                                  Text(
                                    "Version:\n${sharedMethods.deviceInfo['software_version']?.toString()}",
                                    style: theme.labelMedium.override(
                                      fontFamily: theme.labelMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(theme.labelMediumFamily),
                                    ),
                                  ),
                                  Text(
                                    "Mode:\n${sharedMethods.deviceInfo['mode']?.toString()}",
                                    style: theme.labelMedium.override(
                                      fontFamily: theme.labelMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(theme.labelMediumFamily),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(0.0, 1.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        context.pushReplacementNamed(
                                          'HomePage',
                                          extra: <String, dynamic>{
                                            kTransitionInfoKey:
                                                const TransitionInfo(
                                              hasTransition: true,
                                              transitionType: PageTransitionType
                                                  .leftToRight,
                                              duration:
                                                  Duration(milliseconds: 200),
                                            ),
                                          },
                                        );
                                      },
                                      text: 'Disconnect',
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24.0, 0.0, 24.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: theme.primary,
                                        textStyle: theme.titleSmall.override(
                                          fontFamily: theme.titleSmallFamily,
                                          color: theme.primaryText,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey(
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily),
                                        ),
                                        elevation: 0.0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ].divide(const SizedBox(height: 2.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 3, // Number of tabs
                    child: Column(
                      children: <Widget>[
                        TabBar(
                          labelColor: theme.primaryText,
                          unselectedLabelColor: theme.secondaryText,
                          labelStyle: theme.titleMedium.override(
                            fontFamily: theme.titleMediumFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts: GoogleFonts.asMap()
                                .containsKey(theme.titleMediumFamily),
                          ),
                          unselectedLabelStyle: const TextStyle(),
                          indicator: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: theme.alternate,
                              width: 2,
                            ),
                          ),
                          indicatorPadding:
                              const EdgeInsets.fromLTRB(-12, 0, -12, 0),
                          dividerColor: Colors.transparent,
                          dividerHeight: 0.0,
                          tabs: const [
                            Tab(text: 'Stats'),
                            Tab(text: 'Apps'),
                            Tab(text: 'Control Panel'),
                          ],
                        ),
                        const Expanded(
                          child: TabBarView(
                            children: [
                              StatsPageWidget(),
                              AppsPageWidget(),
                              ControlPanelPageWidget(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
