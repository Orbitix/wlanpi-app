import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';
import 'package:wlanpi_mobile/services/token_handler.dart';

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
    final returnMessage = <String, dynamic>{};
    try {
      String response = await _channel.invokeMethod('connectToDevice');

      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response);
        final token =
            await fetchTokenWithSudo("169.254.43.1", 22, "wlanpi", "-", "app");

        print("recieved token: $token");
        if (token != null) {
          await saveToken(token);
        }
        SharedMethodsProvider().device_ip = jsonResponse["ip"];
      } catch (e) {
        returnMessage['success'] = false;
        returnMessage['message'] =
            'Failed to parse JSON response: ${e.toString()}';
        return returnMessage;
      }

      returnMessage['success'] = true;
      returnMessage['message'] = 'Connected successfully';
    } on PlatformException catch (e) {
      returnMessage['success'] = false;
      returnMessage['message'] = 'Platform exception occurred: ${e.message}';
    } catch (e) {
      returnMessage['success'] = false;
      returnMessage['message'] =
          'An unexpected error occurred: ${e.toString()}';
    }
    return returnMessage;
  }

  Future<Map<String, dynamic>> disconnectFromDevice() async {
    final returnMessage = <String, dynamic>{};
    try {
      await _channel.invokeMethod('disconnectFromDevice');
      returnMessage['success'] = true;
      returnMessage['message'] = 'Disconnected successfully';
    } on PlatformException catch (e) {
      returnMessage['success'] = false;
      returnMessage['message'] = 'Platform exception occurred: ${e.message}';
    } catch (e) {
      returnMessage['success'] = false;
      returnMessage['message'] =
          'An unexpected error occurred: ${e.toString()}';
    }
    return returnMessage;
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
