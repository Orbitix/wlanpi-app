import 'dart:async';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wlanpi_mobile/services/network_handler.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';

import 'package:wlanpi_mobile/theme/theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionOptionsBottomSheet extends StatefulWidget {
  const ConnectionOptionsBottomSheet({super.key});

  @override
  State<ConnectionOptionsBottomSheet> createState() =>
      _ConnectionOptionsBottomSheetState();
}

class _ConnectionOptionsBottomSheetState
    extends State<ConnectionOptionsBottomSheet> {
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

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        border: Border(top: BorderSide(color: theme.alternate, width: 2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Connection Options',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w600,
              fontSize: 22.0,
              useGoogleFonts:
                  GoogleFonts.asMap().containsKey(theme.headlineSmallFamily),
            ),
          ),
          const SizedBox(height: 16.0),
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
                    hint: const Text('Select the connection method'),
                    items: transport_types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        transport_type = newValue;
                      });
                      _setTransportType();
                    },
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16.0),
          FFButtonWidget(
            onPressed: () async {
              await _handleButton();
            },
            text: 'Connect',
            options: FFButtonOptions(
              width: double.infinity,
              height: 50.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: theme.primary,
              textStyle: theme.titleSmall.override(
                fontFamily: theme.titleSmallFamily,
                color: Colors.white,
                letterSpacing: 0.0,
                useGoogleFonts:
                    GoogleFonts.asMap().containsKey(theme.titleSmallFamily),
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }
}
