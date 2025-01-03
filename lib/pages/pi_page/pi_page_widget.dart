import 'dart:async';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlanpi_mobile/pages/settings.dart';
import 'package:wlanpi_mobile/services/network_handler.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';
import 'package:wlanpi_mobile/widgets/connection_options_bottom_sheet.dart';

import 'package:wlanpi_mobile/flutter_flow/flutter_flow_animations.dart';
import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:wlanpi_mobile/utils/flutter_flow_util.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wlanpi_mobile/version.dart';

class PiPageWidget extends StatefulWidget {
  const PiPageWidget({super.key});

  @override
  State<PiPageWidget> createState() => _PiPageWidgetState();
}

class _PiPageWidgetState extends State<PiPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  late SharedMethodsProvider sharedMethods;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sharedMethods = Provider.of<SharedMethodsProvider>(context);
  }

  Future<void> _loadIPs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("bluetoothIpAddress") == null) {
      await prefs.setString('bluetoothIpAddress', "169.254.43.1");
    }
    if (prefs.getString("otgIpAddress") == null) {
      await prefs.setString('otgIpAddress', "169.254.42.1");
    }
  }

  Future<void> _disconnectDevice() async {
    var response = await NetworkHandler().disconnectFromDevice();

    if (response["success"]) {
      debugPrint("Successfully disconnected PI");
      sharedMethods.setConnected(false);
    } else {
      print("Failed to disconnect PI");
      print("Error: ${response["message"]}");
    }
  }

  @override
  void initState() {
    super.initState();

    _loadIPs();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _sharedMethodsProvider =
    //       Provider.of<SharedMethodsProvider>(context, listen: false);
    //   if (_sharedMethodsProvider!.connected) {
    //     _sharedMethodsProvider?.getInfo();
    //   }
    // });
  }

  Widget notConnectedWidget() {
    final theme = CustomTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 30.0,
              color: theme.error,
            ),
            SizedBox(width: 10.0),
            Text('Not Connected',
                style: theme.titleLarge.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Text("Connect to a WLANPi device to get started.",
            style: theme.bodyMedium),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: FFButtonWidget(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const ConnectionOptionsBottomSheet(),
              );
            },
            text: 'Connect',
            options: FFButtonOptions(
              width: double.infinity,
              height: 50.0,
              color: theme.primary,
              textStyle: theme.titleSmall,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ].divide(const SizedBox(height: 20.0)),
    );
  }

  Widget connectedWidget(SharedMethodsProvider sharedMethods) {
    final theme = CustomTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 30.0,
              color: theme.secondary,
            ),
            SizedBox(width: 10.0),
            Text(
              'Connected to ${sharedMethods.deviceInfo["name"]}',
              style: theme.titleLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hostname:",
                        style: theme.labelLarge,
                      ),
                      Text(
                        sharedMethods.deviceInfo['hostname'].toString(),
                        style: theme.labelLarge,
                      ),
                    ],
                  );
                case 1:
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Model:",
                        style: theme.labelLarge,
                      ),
                      Text(
                        "WLANPi ${sharedMethods.deviceInfo['model']?.toString()}",
                        style: theme.labelLarge,
                      ),
                    ],
                  );
                case 2:
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Software Version:",
                        style: theme.labelLarge,
                      ),
                      Text(
                        "${sharedMethods.deviceInfo['software_version']?.toString()}",
                        style:
                            theme.labelLarge.copyWith(color: theme.secondary),
                      ),
                    ],
                  );
                case 3:
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Device Mode:",
                        style: theme.labelLarge,
                      ),
                      Text(
                        "${sharedMethods.deviceInfo['mode']?.toString()}",
                        style: theme.labelLarge,
                      ),
                    ],
                  );
                default:
                  return SizedBox.shrink();
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: FFButtonWidget(
            onPressed: _disconnectDevice,
            text: 'Disconnect',
            options: FFButtonOptions(
              width: double.infinity,
              height: 50.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: theme.primary,
              textStyle: theme.titleSmall.override(
                fontFamily: theme.titleSmallFamily,
                color: Colors.white,
                letterSpacing: 0.0,
                useGoogleFonts:
                    GoogleFonts.asMap().containsKey(theme.titleSmallFamily),
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ].divide(const SizedBox(height: 20.0)),
    );
  }

  Widget buildSection(String heading, String text) {
    final theme = CustomTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w600,
              fontSize: 22.0,
              useGoogleFonts:
                  GoogleFonts.asMap().containsKey(theme.headlineSmallFamily),
            ),
          ),
          SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
            child: Text(
              text,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 16.0,
                useGoogleFonts:
                    GoogleFonts.asMap().containsKey(theme.bodyMediumFamily),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          child: Text("My WLANPi", style: theme.titleLarge),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: theme.alternate, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: sharedMethods.connected
                          ? connectedWidget(sharedMethods)
                          : notConnectedWidget(),
                    )),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SettingsPage(),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: theme.alternate, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 10.0),
                              Text("Settings", style: theme.bodyLarge),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_up_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text('WLANPi App - V ${AppVersion.version}',
                    style: theme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCarouselPage(CustomTheme theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(10.0),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(title,
                      style: theme.titleMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(content, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
