import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

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
