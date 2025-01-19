import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class TokenHandler {
  static const MethodChannel _channel =
      MethodChannel('network_interface_binding');

  Future<String?> fetchTokenWithSudo(String host, int port, String username,
      String password, String deviceName) async {
    try {
      print("fetching token via ssh: $host: $port");

      // Establish SSH connection
      final socket = await SSHSocket.connect(host, port);

      final client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password, // For SSH password authentication
      );

      print('SSH connection established.');

      // Command to run the script with sudo and suppress extra output
      final command =
          "echo '$password' | sudo -S getjwt $deviceName 2>/dev/null";

      // Run the command
      final result = await client.run(command);

      // Convert result to a UTF-8 string
      final output = utf8.decode(result);

      print('Raw command output: $output');

      // Clean and parse the JSON output
      final jsonStartIndex = output.indexOf('{');
      final jsonEndIndex = output.lastIndexOf('}');
      if (jsonStartIndex == -1 || jsonEndIndex == -1) {
        throw FormatException('No valid JSON found in command output.');
      }

      final jsonString = output.substring(jsonStartIndex, jsonEndIndex + 1);
      final jsonOutput = jsonDecode(jsonString) as Map<String, dynamic>;

      final accessToken = jsonOutput['access_token'] as String;

      client.close();

      return accessToken;
    } catch (e) {
      print('Error fetching token: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'access_token', value: token);
    print('Token securely stored.');
  }

  Future<String?> getToken() async {
    final token = await storage.read(key: 'access_token');
    print('Retrieved token: $token');
    return token;
  }

  Future<void> clearToken() async {
    await storage.delete(key: 'access_token');
    print('Token cleared from storage.');
  }

  Future<void> sendTokenToNative() async {
    String? token = await storage.read(key: 'access_token');
    print("sending token to native code");

    if (token != null) {
      await _channel.invokeMethod('storeToken', {'token': token});
    }
  }
}
