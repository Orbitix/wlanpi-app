import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskQueue {
  final List<Future<void> Function()> _taskQueue = [];
  bool _isProcessing = false;

  // Add a task to the queue
  void addTask(Future<void> Function() task) {
    _taskQueue.add(task);
    _processQueue();
  }

  // Process the tasks in the queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;

    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeAt(0);
      await task();
    }

    _isProcessing = false;
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class JsonParseException implements Exception {
  final String message;
  JsonParseException(this.message);

  @override
  String toString() => 'JsonParseException: $message';
}

class NetworkHandler {
  static const MethodChannel _channel = MethodChannel('network_handler');
  static const EventChannel _eventChannel = EventChannel('network_status');

  static final _taskQueue = TaskQueue();

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
      _activeUrl = 'http://$_otgIpAddress';
    } else if (status == "bluetooth_connected") {
      _activeUrl = 'http://$_bluetoothIpAddress';
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

  // Wrap your request method with the task queue
  Future<Map<String, dynamic>> requestEndpoint(
      String port, String endpoint, String method) async {
    final completer = Completer<Map<String, dynamic>>();

    _taskQueue.addTask(() async {
      try {
        final dynamic result = await _channel.invokeMethod(
            'makeNetworkRequest', {
          'url': _activeUrl,
          'port': port,
          'endpoint': endpoint,
          'method': method
        });

        if (result == null) {
          throw NetworkException('No response from the native code');
        }

        print("Raw response: $result"); // Log the raw response

        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(result);
          completer.complete(jsonResponse);
        } catch (e) {
          completer.completeError(JsonParseException(
              'Failed to parse JSON response: ${e.toString()}'));
        }
      } on PlatformException catch (e) {
        completer.completeError(
            NetworkException('Platform exception occurred: ${e.message}'));
      } catch (e) {
        completer.completeError(
            Exception('An unexpected error occurred: ${e.toString()}'));
      }
    });

    return completer.future;
  }
}
