import 'dart:async';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wlanpi_mobile/services/network_handler.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '../../theme/theme.dart';
import '../../utils/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PiPageWidget extends StatefulWidget {
  const PiPageWidget({super.key});

  @override
  State<PiPageWidget> createState() => _PiPageWidgetState();
}

class _PiPageWidgetState extends State<PiPageWidget>
    with TickerProviderStateMixin {
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
        // context.pushNamed('DevicePage');
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

    _loadIPs();
    _loadPreferences();
  }

  Widget buildSection(String heading, String text) {
    final theme = CustomTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w600,
              fontSize: 22.0,
              useGoogleFonts:
                  GoogleFonts.asMap().containsKey(theme.headlineSmallFamily),
            ),
          ),
          SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
            child: Text(
              text,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 16.0,
                useGoogleFonts:
                    GoogleFonts.asMap().containsKey(theme.bodyMediumFamily),
              ),
            ),
          ),
        ],
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
        automaticallyImplyLeading: false,
        title: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          child: Text("My WLANPi", style: theme.titleLarge),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                        color: sharedMethods.connected
                            ? theme.success
                            : theme.alternate,
                        width: 2),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 30.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                  sharedMethods.connected
                                      ? 'Connected'
                                      : 'Not Connected',
                                  style: theme.headlineSmall
                                      .copyWith(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Text("Connect to a WLANPi device to get started.",
                              style: theme.bodyMedium),
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
                                inactiveTrackColor: Colors.transparent,
                              ),
                              if (useCustomTransport) ...[
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.alternate,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: theme.alternate,
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
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: theme.alternate, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 10.0),
                            Text("Settings", style: theme.bodyLarge),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'V 0.5.2',
                  style: theme.labelSmall.override(
                    fontFamily: theme.labelSmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey(theme.labelSmallFamily),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCarouselPage(CustomTheme theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(title,
                      style: theme.titleMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(content, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
