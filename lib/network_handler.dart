
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NetworkHandler {
  static const MethodChannel _channel = MethodChannel('network_handler');

  static const EventChannel _eventChannel = EventChannel('network_status');

  String? _otgIpAddress;

  String? _bluetoothIpAddress;

  String? _activeUrl;

  NetworkHandler() {
    _loadSettings();

    _eventChannel.receiveBroadcastStream().listen(_onStatusChange);
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _otgIpAddress = prefs.getString('otgIpAddress') ?? '169.254.42.1';

    _bluetoothIpAddress =
        prefs.getString('bluetoothIpAddress') ?? '169.254.43.1';
  }

  void _onStatusChange(dynamic status) {
    // Update connection status and attempt reconnection if needed

    if (status == "usb_otg_connected") {
      _activeUrl = 'https://$_otgIpAddress';
    } else if (status == "bluetooth_connected") {
      _activeUrl = 'https://$_bluetoothIpAddress';
    } else {
      _activeUrl = null;
    }
  }

  Future<void> checkAndConnect() async {
    try {
      final result = await _channel.invokeMethod('checkAndConnect', {
        'otgIpAddress': _otgIpAddress,
        'bluetoothIpAddress': _bluetoothIpAddress,
      });

      _activeUrl = result;
    } on PlatformException catch (e) {
      print('Failed to connect: ${e.message}');
    }
  }

  String? get activeUrl => _activeUrl;
}
