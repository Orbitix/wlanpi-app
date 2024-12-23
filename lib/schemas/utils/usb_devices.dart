import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';
import 'package:wlanpi_mobile/json_widget_builder.dart';

class UsbDevicesWidget extends StatelessWidget {
  const UsbDevicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return EndpointDataFetcher(
      endpoint: "/api/v1/utils/usb",
      method: "GET",
      builder: (context, json) {
        final List usbInterfaces = json['interfaces'] ?? ['N/A'];

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...usbInterfaces.map((usbInterface) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "- ${usbInterface.toString()}",
                    style: theme.bodyMedium,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
