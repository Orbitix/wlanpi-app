import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';

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
  static const MethodChannel _channel =
      MethodChannel('network_interface_binding');

  NetworkHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onNetworkDisconnected") {
        debugPrint("Setting Disconnect state");
        SharedMethodsProvider().setConnected(false);
        SharedMethodsProvider().stopStatsTimer();
      }
      return null;
    });
  }

  // connect and disconnect methods
  Future<Map<String, dynamic>> connectToDevice() async {
    final response = <String, dynamic>{};
    try {
      await _channel.invokeMethod('connectToDevice');
      response['success'] = true;
      response['message'] = 'Connected successfully';
    } on PlatformException catch (e) {
      response['success'] = false;
      response['message'] = 'Platform exception occurred: ${e.message}';
    } catch (e) {
      response['success'] = false;
      response['message'] = 'An unexpected error occurred: ${e.toString()}';
    }
    return response;
  }

  Future<Map<String, dynamic>> disconnectFromDevice() async {
    final response = <String, dynamic>{};
    try {
      await _channel.invokeMethod('disconnectFromDevice');
      response['success'] = true;
      response['message'] = 'Disconnected successfully';
    } on PlatformException catch (e) {
      response['success'] = false;
      response['message'] = 'Platform exception occurred: ${e.message}';
    } catch (e) {
      response['success'] = false;
      response['message'] = 'An unexpected error occurred: ${e.toString()}';
    }
    return response;
  }

  Future<bool> testDevice() async {
    try {
      print("Testing device api");
      Map<String, dynamic> response =
          await requestEndpoint("31415", "/api/v1/system/device/model", "GET");

      if (response.containsKey("Error")) {
        print("Failed to contact api");
        return false;
      } else {
        return true;
      }
    } catch (error) {
      print("Error occurred while testing device: $error");
      return false;
    }
  }

  // Request method - it will be handled by Kotlin task queue
  Future<Map<String, dynamic>> requestEndpoint(
      String port, String endpoint, String method) async {
    final completer = Completer<Map<String, dynamic>>();

    try {
      final dynamic result = await _channel.invokeMethod('connectToEndpoint',
          {'port': port, 'endpoint': endpoint, 'method': method});

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

    return completer.future;
  }
}
