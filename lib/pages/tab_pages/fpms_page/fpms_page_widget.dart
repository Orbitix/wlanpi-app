import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/shared_methods.dart';
import 'package:wlanpi_mobile/pages/tab_pages/fpms_page/dymanic_menu_page.dart';
import 'package:wlanpi_mobile/network_handler.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class FPMSPageWidget extends StatefulWidget {
  const FPMSPageWidget({super.key});

  @override
  State<FPMSPageWidget> createState() => _FPMSPageWidgetState();
}

void show_popup(BuildContext context, String title, String message) {
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

Future<String> action_func(String endpoint, String method) async {
  try {
    final response =
        await NetworkHandler().requestEndpoint("31415", endpoint, method);
    String message = parseJsonToReadableText(response);
    return message;
  } catch (e) {
    return "Error: $e";
  }
}

Future<void> pressed_func(
    BuildContext context, String title, String endpoint, String method) async {
  try {
    final response =
        await NetworkHandler().requestEndpoint("31415", endpoint, method);
    String message = parseJsonToReadableText(response);
    show_popup(context, title, message);
  } catch (e) {
    show_popup(context, title, "$e");
  }
}

Future<void> bluetooth_on(BuildContext context) async {
  try {
    final response = await NetworkHandler()
        .requestEndpoint("31415", "/api/v1/bluetooth/power/on", "POST");
    String message = parseJsonToReadableText(response);
    show_popup(context, "Bluetooth Power", message);
  } catch (e) {
    show_popup(context, "Bluetooth Power", "$e");
  }
}

Future<void> bluetooth_off(BuildContext context) async {
  try {
    final response = await NetworkHandler()
        .requestEndpoint("31415", "/api/v1/bluetooth/power/off", "POST");
    String message = parseJsonToReadableText(response);
    show_popup(context, "Bluetooth Power", message);
  } catch (e) {
    show_popup(context, "Bluetooth Power", "$e");
  }
}

// Define the menu structure in Flutter
final List<MenuItem> menuData = [
  MenuItem(
    title: "Network",
    subItems: [
      MenuItem(
          title: "Network Info",
          action: () => action_func("/api/v1/network/info", "GET")),
    ],
  ),
  MenuItem(
    title: "Bluetooth",
    subItems: [
      MenuItem(
          title: "Status",
          action: () => action_func("/api/v1/bluetooth/status", "GET")),
      MenuItem(title: "Turn On", onPressed: bluetooth_on),
      MenuItem(title: "Turn Off", onPressed: bluetooth_off),
    ],
  ),
  MenuItem(
    title: "Utils",
    subItems: [
      MenuItem(
          title: "Reachability",
          action: () => action_func("/api/v1/utils/reachability", "GET")),
      MenuItem(
          title: "Speedtest",
          action: () => action_func("/api/v1/utils/speedtest", "GET")),
      MenuItem(
          title: "USB Devices",
          action: () => action_func("/api/v1/utils/usb", "GET")),
      MenuItem(
          title: "UFW Ports",
          action: () => action_func("/api/v1/utils/ufw", "GET")),
    ],
  ),
  MenuItem(
    title: "Apps",
    subItems: [
      MenuItem(
        title: "Kismet",
        subItems: [
          MenuItem(
              title: "Start",
              action: () => action_func(
                  "/api/v1/system/service/start?name=kismet", "POST")),
          MenuItem(
              title: "Stop",
              action: () => action_func(
                  "/api/v1/system/service/stop?name=kismet", "POST")),
        ],
      ),
      MenuItem(
        title: "Scanner",
        subItems: [
          MenuItem(
              title: "Scan",
              action: () => action_func("/api/v1/utils/ufw", "GET")),
          MenuItem(
              title: "Scan (no hidden)",
              action: () => action_func("/api/v1/utils/ufw", "GET")),
          MenuItem(
              title: "Scan to CSV",
              action: () => action_func("/api/v1/utils/ufw", "GET")),
          MenuItem(
            title: "Scan to PCAP",
            subItems: [
              MenuItem(
                  title: "Start",
                  action: () => action_func("/api/v1/utils/ufw", "GET")),
              MenuItem(
                  title: "Stop",
                  action: () => action_func("/api/v1/utils/ufw", "GET")),
            ],
          ),
        ],
      ),
    ],
  ),
  MenuItem(
    title: "System",
    subItems: [
      MenuItem(
          title: "About",
          action: () => action_func("/api/v1/utils/ufw", "GET")),
      MenuItem(
          title: "Help", action: () => action_func("/api/v1/utils/ufw", "GET")),
      MenuItem(
          title: "Summary",
          action: () => action_func("/api/v1/system/device/stats", "GET")),
      MenuItem(
          title: "Battery",
          action: () => action_func("/api/v1/utils/ufw", "GET")),
      MenuItem(
        title: "Settings",
        subItems: [
          MenuItem(
            title: "Date & Time",
            subItems: [
              MenuItem(
                  title: "Show Time & Zone",
                  action: () => action_func("/api/v1/utils/ufw", "GET")),
              MenuItem(
                title: "Set Timezone",
                subItems: [
                  MenuItem(
                      title: "Auto",
                      action: () => action_func("/api/v1/utils/ufw", "GET")),
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
                  action: () => action_func("/api/v1/utils/ufw", "GET")),
              // Add other RF Domain settings here
            ],
          ),
          MenuItem(
              title: "Rotate Display",
              action: () => action_func("/api/v1/utils/ufw", "GET")),
        ],
      ),
      MenuItem(
        title: "Reboot",
        subItems: [
          MenuItem(
              title: "Confirm",
              action: () => action_func("/api/v1/utils/ufw", "GET"))
        ],
      ),
      MenuItem(
        title: "Shutdown",
        subItems: [
          MenuItem(
              title: "Confirm",
              action: () => action_func("/api/v1/utils/ufw", "GET"))
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

class _FPMSPageWidgetState extends State<FPMSPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
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
