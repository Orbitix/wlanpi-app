import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

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

class NetworkUtils {
  static const platform = MethodChannel('network_interface_binding');
  static final _taskQueue = TaskQueue();

  // Wrap your request method with the task queue
  static Future<Map<String, dynamic>> requestEndpoint(
      String endpoint, String method) async {
    final completer = Completer<Map<String, dynamic>>();

    _taskQueue.addTask(() async {
      try {
        final dynamic result = await platform.invokeMethod(
            'connectToEndpoint', {
          'endpoint': "http://169.254.43.1:31415$endpoint",
          'method': method
        });

        if (result == null) {
          throw NetworkException('No response from the native code');
        }

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
