import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wlanpi_mobile/network_handler.dart'; // Updated import

class SharedMethods {
  final Function(void Function()) setStateCallback;
  final BuildContext context;

  // Create an instance of NetworkHandler
  final NetworkHandler networkHandler = NetworkHandler();

  SharedMethods(this.setStateCallback, this.context);

  Timer? timer;

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

  Map<String, dynamic> deviceInfo = {};
  Map<String, dynamic> deviceStats = {};
  Map<String, dynamic> kismetStatus = {};
  Map<String, dynamic> grafanaStatus = {};

  void initializeData() {
    // Initialize your variables with default values or fetch data.
    deviceInfo = _defaultDeviceInfo;
    deviceStats = _defaultDeviceStats;
    kismetStatus = _defaultKismetStatus;
    grafanaStatus = _defaultGrafanaStatus;
  }

  Future<void> apiResponse(String response) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('API Response'),
          content: Text("API responded with: $response"),
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

  void getInfo() async {
    try {
      final response = await networkHandler.requestEndpoint(
          "31415", "/api/v1/system/device/info", "GET");
      deviceInfo = response;
    } catch (error) {
      print("Error fetching data: $error");
      deviceInfo = _defaultDeviceInfo;
    }
    setStateCallback(() {});
  }

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
    setStateCallback(() {});
  }

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
      setStateCallback(() {});
    });
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
