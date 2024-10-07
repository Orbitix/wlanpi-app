import 'package:flutter/material.dart';
import 'dart:async';

import 'package:wlanpi_mobile/network_utils.dart';

class SharedMethods {
  final Function(void Function()) setStateCallback;
  final BuildContext context;

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
      if (status) {
        return await NetworkUtils.requestEndpoint(
            "/api/v1/system/service/stop?name=$service", "POST");
      } else {
        return await NetworkUtils.requestEndpoint(
            "/api/v1/system/service/start?name=$service", "POST");
      }
    } catch (error) {
      print("Error fetching data: $error");
      if (service == "kismet") {
        return _defaultKismetStatus;
      } else {
        return _defaultGrafanaStatus;
      }
    } finally {
      getServiceStatus();
    }
  }

  void getInfo() async {
    try {
      deviceInfo = await NetworkUtils.requestEndpoint(
          "/api/v1/system/device/info", "GET");
    } catch (error) {
      print("Error fetching data: $error");
      deviceInfo = _defaultDeviceInfo;
    }
    setStateCallback(() {});
  }

  void getServiceStatus() async {
    try {
      kismetStatus = await NetworkUtils.requestEndpoint(
          "/api/v1/system/service/status?name=kismet", "GET");
    } catch (error) {
      print("Error fetching data: $error");
      kismetStatus = _defaultKismetStatus;
    }
    try {
      grafanaStatus = await NetworkUtils.requestEndpoint(
          "/api/v1/system/service/status?name=grafana", "GET");
    } catch (error) {
      print("Error fetching data: $error");
      grafanaStatus = _defaultGrafanaStatus;
    }
    setStateCallback(() {});
  }

  void startStatsTimer() async {
    try {
      deviceStats = await NetworkUtils.requestEndpoint(
          "/api/v1/system/device/stats", "GET");

      kismetStatus = await NetworkUtils.requestEndpoint(
          "/api/v1/system/service/status?name=kismet", "GET");

      grafanaStatus = await NetworkUtils.requestEndpoint(
          "/api/v1/system/service/status?name=grafana-server", "GET");
    } catch (error) {
      print("Error fetching data: $error");
      deviceStats = _defaultDeviceStats;
      kismetStatus = _defaultKismetStatus;
      grafanaStatus = _defaultGrafanaStatus;
    }
    setStateCallback(() {});

    // Schedule the fetch every 2 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        deviceStats = await NetworkUtils.requestEndpoint(
            "/api/v1/system/device/stats", "GET");

        kismetStatus = await NetworkUtils.requestEndpoint(
            "/api/v1/system/service/status?name=kismet", "GET");

        grafanaStatus = await NetworkUtils.requestEndpoint(
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
