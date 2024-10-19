import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wlanpi_mobile/network_handler.dart';

class SharedMethodsProvider extends ChangeNotifier {
  // Singleton pattern
  static final SharedMethodsProvider _instance =
      SharedMethodsProvider._internal();
  factory SharedMethodsProvider() => _instance;
  SharedMethodsProvider._internal() {
    initializeData(); // Initialize data when the instance is created
  }

  final NetworkHandler networkHandler = NetworkHandler();
  Timer? timer;

  // Default values
  final Map<String, dynamic> _defaultDeviceInfo = {
    "model": "-",
    "name": "-",
    "hostname": "-",
    "software_version": "-",
    "mode": "-"
  };

  final Map<String, dynamic> _defaultDeviceStats = {
    "ip": "-",
    "cpu": "-",
    "ram": "- -",
    "disk": "- -",
    "cpu_temp": "-",
    "uptime": "-",
  };

  final Map<String, dynamic> _defaultKismetStatus = {
    "active": false,
  };

  final Map<String, dynamic> _defaultGrafanaStatus = {
    "active": false,
  };

  // Shared state
  Map<String, dynamic> deviceInfo = {};
  Map<String, dynamic> deviceStats = {};
  Map<String, dynamic> kismetStatus = {};
  Map<String, dynamic> grafanaStatus = {};

  // Initialize the data
  void initializeData() {
    deviceInfo = _defaultDeviceInfo;
    deviceStats = _defaultDeviceStats;
    kismetStatus = _defaultKismetStatus;
    grafanaStatus = _defaultGrafanaStatus;
    notifyListeners(); // Notify listeners to refresh the UI
  }

  // Start and stop service
  Future<Map<String, dynamic>> startStopService(
      bool status, String service) async {
    try {
      String action = status ? "stop" : "start";
      String endpoint = "/api/v1/system/service/$action?name=$service";
      final response =
          await networkHandler.requestEndpoint("31415", endpoint, "POST");
      return response;
    } catch (error) {
      print("Error fetching data: $error");
      return service == "kismet" ? _defaultKismetStatus : _defaultGrafanaStatus;
    } finally {
      getServiceStatus();
    }
  }

  // Get device information
  void getInfo() async {
    try {
      final response = await networkHandler.requestEndpoint(
          "31415", "/api/v1/system/device/info", "GET");
      deviceInfo = response;
    } catch (error) {
      print("Error fetching data: $error");
      deviceInfo = _defaultDeviceInfo;
    }
    notifyListeners(); // Notify listeners about the change
  }

  // Get service status
  void getServiceStatus() async {
    try {
      kismetStatus = await networkHandler.requestEndpoint(
          "31415", "/api/v1/system/service/status?name=kismet", "GET");
    } catch (error) {
      print("Error fetching data: $error");
      kismetStatus = _defaultKismetStatus;
    }

    try {
      grafanaStatus = await networkHandler.requestEndpoint(
          "31415", "/api/v1/system/service/status?name=grafana", "GET");
    } catch (error) {
      print("Error fetching data: $error");
      grafanaStatus = _defaultGrafanaStatus;
    }
    notifyListeners();
  }

  // Start timer
  void startStatsTimer() async {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        deviceStats = await networkHandler.requestEndpoint(
            "31415", "/api/v1/system/device/stats", "GET");

        kismetStatus = await networkHandler.requestEndpoint(
            "31415", "/api/v1/system/service/status?name=kismet", "GET");

        grafanaStatus = await networkHandler.requestEndpoint("31415",
            "/api/v1/system/service/status?name=grafana-server", "GET");
      } catch (error) {
        print("Error fetching data: $error");
        deviceStats = _defaultDeviceStats;
        kismetStatus = _defaultKismetStatus;
        grafanaStatus = _defaultGrafanaStatus;
      }
      notifyListeners(); // Notify listeners every time data is updated
    });
  }

  // Stop timer
  void stopStatsTimer() {
    timer?.cancel();
    notifyListeners(); // Optionally notify listeners when the timer stops
  }
}
