import 'package:wlanpi_mobile/schemas/network_info/network_info.dart';
import 'package:wlanpi_mobile/schemas/system/summary.dart';
import 'package:wlanpi_mobile/schemas/utils/reachability.dart';
import 'package:wlanpi_mobile/schemas/utils/ufw_ports.dart';
import 'package:wlanpi_mobile/schemas/utils/usb_devices.dart';
import 'package:wlanpi_mobile/shared_methods.dart';
import 'package:wlanpi_mobile/pages/tab_pages/control_panel_page/dynamic_menu_page.dart';
import 'package:wlanpi_mobile/network_handler.dart';
import 'package:wlanpi_mobile/schemas/bluetooth/bluetooth_status.dart';

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

// Future<String> actionFunc(String endpoint, String method) async {
//   try {
//     final response =
//         await NetworkHandler().requestEndpoint("31415", endpoint, method);
//     String message = parseJsonToReadableText(response);
//     return message;
//   } catch (e) {
//     return "Error: $e";
//   }
// }

Future<Map<String, dynamic>> actionFunc(String endpoint, String method) async {
  try {
    final response =
        await NetworkHandler().requestEndpoint("31415", endpoint, method);
    return response;
  } catch (e) {
    return {"error": e};
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
      MenuItem(title: "Network Info", widget: NetworkInfoWidget()),
    ],
  ),
  MenuItem(
    title: "Bluetooth",
    subItems: [
      MenuItem(title: "Status", widget: BluetoothStatusWidget()),
      MenuItem(title: "Turn On", onPressed: bluetoothOn),
      MenuItem(title: "Turn Off", onPressed: bluetoothOff),
    ],
  ),
  MenuItem(
    title: "Utils",
    subItems: [
      MenuItem(title: "Reachability", widget: ReachabilityWidget()),
      MenuItem(title: "USB Devices", widget: UsbDevicesWidget()),
      MenuItem(title: "UFW Ports", widget: UfwPortsWidget()),
    ],
  ),
  MenuItem(
    title: "System",
    subItems: [
      MenuItem(title: "Summary", widget: SystemSummaryWidget()),
      MenuItem(
        title: "Settings",
        subItems: [
          MenuItem(
            title: "Date & Time",
            subItems: [
              MenuItem(
                  title: "Show Time & Zone", widget: BluetoothStatusWidget()),
              MenuItem(
                title: "Set Timezone",
                subItems: [
                  MenuItem(title: "Auto", widget: BluetoothStatusWidget()),
                  // Add other time zone actions here
                ],
              ),
            ],
          ),
          MenuItem(
            title: "RF Domain",
            subItems: [
              MenuItem(title: "Show Domain", widget: BluetoothStatusWidget()),
              // Add other RF Domain settings here
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Reboot",
        subItems: [MenuItem(title: "Confirm", widget: BluetoothStatusWidget())],
      ),
      MenuItem(
        title: "Shutdown",
        subItems: [MenuItem(title: "Confirm", widget: BluetoothStatusWidget())],
      ),
    ],
  ),
];

class MenuItem {
  final String title;
  final Widget? widget;
  final Future<void> Function(BuildContext)? onPressed;
  final List<MenuItem>? subItems;

  MenuItem({
    required this.title,
    this.widget,
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
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
          ),
          child: DynamicMenuPage(menuItems: menuData),
        ),
      ),
    );
  }
}
