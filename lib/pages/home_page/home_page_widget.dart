import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlanpi_mobile/network_handler.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  String? transport_type = "Bluetooth";
  final List<String> transport_types = ['Bluetooth', 'USB OTG'];

  bool useCustomTransport = false;

  Future<void> _setTransportType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('transportType', transport_type!);

    await _testDevice();
  }

  Future<void> _setUseCustomTransport(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCustomTransport', value);
  }

  Future<void> _handleButton() async {
    try {
      await _setTransportType().timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Operation Timed Out");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      useCustomTransport = prefs.getBool('useCustomTransport') ?? false;
      transport_type = prefs.getString('transportType') ?? 'Bluetooth';
    });
  }

  Future<void> _testDevice() async {
    try {
      Map<String, dynamic> response = await NetworkHandler()
          .requestEndpoint("31415", "/api/v1/system/device/model", "GET");

      if (response.containsKey("Error")) {
        print("Failed to contact PI");
        failedConnection();
      } else {
        context.pushNamed('DevicePage');
      }
    } catch (error) {
      print("Error occurred while testing device: $error");
      failedConnection(); // Call the failedConnection method on error
    }
  }

  Future<void> failedConnection() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Device Connection Failed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "We couldn't contact this PI. Check that it has a PAN address on the home screen."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadIPs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("bluetoothIpAddress") == null) {
      await prefs.setString('bluetoothIpAddress', "169.254.43.1");
    }
    if (prefs.getString("otgIpAddress") == null) {
      await prefs.setString('otgIpAddress', "169.254.42.1");
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    _loadIPs();
    _loadPreferences();

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
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.secondaryBackground,
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
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    context.pushNamed('SettingsPage');
                  },
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.alternate,
                              borderRadius: BorderRadius.circular(10.0),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'Connect To a PI',
                                    style: theme.headlineMedium.override(
                                      fontFamily: theme.headlineMediumFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              theme.headlineMediumFamily),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              fadeInDuration: const Duration(milliseconds: 500),
                              fadeOutDuration:
                                  const Duration(milliseconds: 500),
                              imageUrl:
                                  'https://images.squarespace-cdn.com/content/v1/5f80b3793732d0058da4a694/1668978349491-XJIVZ3CIASIBXGXRGRJ8/WLAN+Pi+M4+v86-A1.png?format=2500w',
                              width: 300.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Column(
                            children: [
                              SwitchListTile(
                                title: Text('Connection Method Override'),
                                value: useCustomTransport,
                                onChanged: (bool value) {
                                  setState(() {
                                    useCustomTransport = value;
                                  });
                                  _setUseCustomTransport(value);
                                },
                                activeColor: theme.primary,
                                activeTrackColor: theme.accent1,
                                inactiveTrackColor: theme.primaryBackground,
                              ),
                              if (useCustomTransport) ...[
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: transport_type,
                                        hint: const Text(
                                            'Select the connection method'),
                                        items:
                                            transport_types.map((String type) {
                                          return DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(type),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            transport_type = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                await _handleButton();
                              },
                              text: 'Connect',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: theme.primary,
                                textStyle: theme.titleSmall.override(
                                  fontFamily: theme.titleSmallFamily,
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: GoogleFonts.asMap()
                                      .containsKey(theme.titleSmallFamily),
                                ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 10.0)),
                      )),
                ),
                Text(
                  'V 0.2',
                  style: theme.labelSmall.override(
                    fontFamily: theme.labelSmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey(theme.labelSmallFamily),
                  ),
                ),
              ].divide(const SizedBox(height: 10.0)),
            ),
          ),
        ),
      ),
    );
  }
}
