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
  final List<String> transport_types = ['Bluetooth', 'USB OTG', 'LAN'];
  String? transport_type = "Bluetooth";
  bool useCustomTransport = false;

  String statusMessage = "Connecting...";

  late SharedMethodsProvider sharedMethods;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sharedMethods = Provider.of<SharedMethodsProvider>(context);
  }

  Future<void> _setTransportType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('transportType', transport_type!);
    await _connectDevice();
  }

  Future<void> _setUseCustomTransport(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCustomTransport', value);
  }

  Future<void> _handleButton() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (transport_type == "LAN" &&
        prefs.getString('LANIpAddress') == "wlanpi-xxx.local") {
      debugPrint("LAN IP not configured");
      failedConnection(
          "Please set the LAN address of your Pi before connecting.\nYou can do this in the settings tab on the Pi Page.");
    } else {
      try {
        await _setTransportType().timeout(Duration(seconds: 15), onTimeout: () {
          failedConnection(
              "Connection Timed Out.\nMake sure you have a device connected over bluetooth or USB.");
          throw TimeoutException("Operation Timed Out");
        });
      } catch (e) {
        print(e);
      }
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
    statusMessage = "Testing API...";
    bool response = await NetworkHandler().testDevice();

    if (response) {
      sharedMethods.getInfo();
      Navigator.of(context).pop();
    } else {
      failedConnection(
          "Contacting Device Failed.\nThis means that the device was connected, but your Pi either doesn't support the API, or the port (31415) is not open.");
    }
  }

  Future<void> _connectDevice() async {
    var response = await NetworkHandler().connectToDevice();

    if (response["success"]) {
      debugPrint("Successfully connected to PI");
      sharedMethods.setConnected(true);
      await _testDevice();
    } else {
      print("Failed to connect to PI");
      print("Error: ${response["message"]}");
      failedConnection("Connecting to device failed.");
    }
  }

  Future<void> failedConnection(String message) async {
    final theme = CustomTheme.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.secondaryBackground,
          title: Text('Device Connection Failed', style: theme.headlineSmall),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: TextButton(
                child: Text('Ok', style: theme.titleSmall),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
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
            showLoadingText: true,
            loadingText: statusMessage,
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
