import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bluetooth_connection_model.dart';
export 'bluetooth_connection_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothConnectionWidget extends StatefulWidget {
  const BluetoothConnectionWidget({super.key});

  @override
  State<BluetoothConnectionWidget> createState() =>
      _BluetoothConnectionWidgetState();
}

class _BluetoothConnectionWidgetState extends State<BluetoothConnectionWidget> {
  late BluetoothConnectionModel _model;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  var scanResults = []; // Declare scanResults here

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _model = createModel(context, () => BluetoothConnectionModel());
  }

  Future<void> bluetoothAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Failed!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bluetooth failed to initialise'),
                Text('Bluetooth permissions are not granted'),
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

  Future<void> alreadyConnected() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Device Already Connected'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This device is already connected.'),
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
                Text("We couldn't connect to this device."),
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

  void requestPermissions() async {
    // Request necessary permissions
    print("requesting bluetooth permission");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // Check if permissions are granted
    if (statuses[Permission.bluetooth] != PermissionStatus.granted ||
        statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
        statuses[Permission.bluetoothConnect] != PermissionStatus.granted ||
        statuses[Permission.locationWhenInUse] != PermissionStatus.granted) {
      bluetoothAlert();
    } else {
      // Start scanning for Bluetooth devices
      flutterBlue.scanResults.listen((List<ScanResult> results) {
        // Process scan results
        setState(() {
          scanResults =
              results.where((result) => result.device.name.isNotEmpty).toList();
          // results;
          // print("\n${scanResults}");
        });
      });

      flutterBlue.startScan(timeout: const Duration(seconds: 30));
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice != null && _connectedDevice!.id == device.id) {
      print('Device ${device.name} is already connected.');
      alreadyConnected();
      return;
    }

    try {
      await device.connect();
      _connectedDevice = device;
      print('Connected to ${device.name}');
      context.pushNamed('DevicePage');

      // Handle successful connection
    } catch (e) {
      print('Error connecting to device: $e');
      failedConnection();
      // Handle connection failure
    }
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pushNamed('HomePage');
            },
          ),
          title: Text(
            'Connect Via Bluetooth',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: GoogleFonts.asMap().containsKey(
                      FlutterFlowTheme.of(context).headlineMediumFamily),
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    'Available Devices',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelLargeFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              FlutterFlowTheme.of(context).labelLargeFamily),
                        ),
                  ),
                ),
                Expanded(
                  child: scanResults.isEmpty
                      ? const Center(
                          child: Text('No Bluetooth devices found.'),
                        )
                      : ListView.builder(
                          itemCount: scanResults
                              .length, // Replace with your device list length
                          itemBuilder: (context, index) {
                            BluetoothDevice device = scanResults[index].device;

                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    device.name.isEmpty
                                        ? device.id.toString()
                                        : device.name,
                                    style: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .labelLargeFamily,
                                          letterSpacing: 0.0,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey(
                                                  FlutterFlowTheme.of(context)
                                                      .labelLargeFamily),
                                        ),
                                  ),
                                  FFButtonWidget(
                                    onPressed: () async {
                                      _connectToDevice(device);
                                    },
                                    text: 'Connect',
                                    options: FFButtonOptions(
                                      height: 40.0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
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
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
