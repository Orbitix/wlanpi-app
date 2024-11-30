import 'package:wlanpi_mobile/shared_methods.dart';
import 'package:wlanpi_mobile/pages/tab_pages/control_panel_page/dynamic_menu_page.dart';
import 'package:wlanpi_mobile/network_handler.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class ControlPanelPageWidget extends StatefulWidget {
  const ControlPanelPageWidget({super.key});

  @override
  State<ControlPanelPageWidget> createState() => _ControlPanelPageWidgetState();
}

void showPopup(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

Future<String> actionFunc(String endpoint, String method) async {
  try {
    final response =
        await NetworkHandler().requestEndpoint("31415", endpoint, method);
    String message = parseJsonToReadableText(response);
    return message;
  } catch (e) {
    return "Error: $e";
  }
}

Future<void> pressedFunc(
    BuildContext context, String title, String endpoint, String method) async {
  try {
    final response =
        await NetworkHandler().requestEndpoint("31415", endpoint, method);
    String message = parseJsonToReadableText(response);
    showPopup(context, title, message);
  } catch (e) {
    showPopup(context, title, "$e");
  }
}

Future<void> bluetoothOn(BuildContext context) async {
  try {
    final response = await NetworkHandler()
        .requestEndpoint("31415", "/api/v1/bluetooth/power/on", "POST");
    String message = parseJsonToReadableText(response);
    showPopup(context, "Bluetooth Power", message);
  } catch (e) {
    showPopup(context, "Bluetooth Power", "$e");
  }
}

Future<void> bluetoothOff(BuildContext context) async {
  try {
    final response = await NetworkHandler()
        .requestEndpoint("31415", "/api/v1/bluetooth/power/off", "POST");
    String message = parseJsonToReadableText(response);
    showPopup(context, "Bluetooth Power", message);
  } catch (e) {
    showPopup(context, "Bluetooth Power", "$e");
  }
}

// Define the menu structure in Flutter
final List<MenuItem> menuData = [
  MenuItem(
    title: "Network",
    subItems: [
      MenuItem(
          title: "Network Info",
          action: () => actionFunc("/api/v1/network/info", "GET")),
    ],
  ),
  MenuItem(
    title: "Bluetooth",
    subItems: [
      MenuItem(
          title: "Status",
          action: () => actionFunc("/api/v1/bluetooth/status", "GET")),
      MenuItem(title: "Turn On", onPressed: bluetoothOn),
      MenuItem(title: "Turn Off", onPressed: bluetoothOff),
    ],
  ),
  MenuItem(
    title: "Utils",
    subItems: [
      MenuItem(
          title: "Reachability",
          action: () => actionFunc("/api/v1/utils/reachability", "GET")),
      MenuItem(
          title: "USB Devices",
          action: () => actionFunc("/api/v1/utils/usb", "GET")),
      MenuItem(
          title: "UFW Ports",
          action: () => actionFunc("/api/v1/utils/ufw", "GET")),
    ],
  ),
  MenuItem(
    title: "System",
    subItems: [
      MenuItem(
          title: "Summary",
          action: () => actionFunc("/api/v1/system/device/stats", "GET")),
      MenuItem(
          title: "Battery",
          action: () => actionFunc("/api/v1/utils/ufw", "GET")),
      MenuItem(
        title: "Settings",
        subItems: [
          MenuItem(
            title: "Date & Time",
            subItems: [
              MenuItem(
                  title: "Show Time & Zone",
                  action: () => actionFunc("/api/v1/utils/ufw", "GET")),
              MenuItem(
                title: "Set Timezone",
                subItems: [
                  MenuItem(
                      title: "Auto",
                      action: () => actionFunc("/api/v1/utils/ufw", "GET")),
                  // Add other time zone actions here
                ],
              ),
            ],
          ),
          MenuItem(
            title: "RF Domain",
            subItems: [
              MenuItem(
                  title: "Show Domain",
                  action: () => actionFunc("/api/v1/utils/ufw", "GET")),
              // Add other RF Domain settings here
            ],
          ),
          MenuItem(
              title: "Rotate Display",
              action: () => actionFunc("/api/v1/utils/ufw", "GET")),
        ],
      ),
      MenuItem(
        title: "Reboot",
        subItems: [
          MenuItem(
              title: "Confirm",
              action: () => actionFunc("/api/v1/utils/ufw", "GET"))
        ],
      ),
      MenuItem(
        title: "Shutdown",
        subItems: [
          MenuItem(
              title: "Confirm",
              action: () => actionFunc("/api/v1/utils/ufw", "GET"))
        ],
      ),
    ],
  ),
];

class MenuItem {
  final String title;
  final Future<String> Function()? action; // For static data fetching actions
  final Future<void> Function(BuildContext)?
      onPressed; // For button actions (POST requests)
  final List<MenuItem>? subItems;

  MenuItem({
    required this.title,
    this.action,
    this.onPressed,
    this.subItems = const [],
  });
}

class _ControlPanelPageWidgetState extends State<ControlPanelPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        top: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
          child: DynamicMenuPage(menuItems: menuData),
        ),
      ),
    );
  }
}
