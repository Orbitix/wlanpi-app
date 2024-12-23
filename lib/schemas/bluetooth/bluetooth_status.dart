import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';
import 'package:wlanpi_mobile/json_widget_builder.dart';

class BluetoothStatusWidget extends StatelessWidget {
  const BluetoothStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return EndpointDataFetcher(
      endpoint: "/api/v1/bluetooth/status",
      method: "GET",
      builder: (context, json) {
        final String name = json['name'] ?? 'N/A';
        final String alias = json['alias'] ?? 'N/A';
        final String addr = json['addr'] ?? 'N/A';
        final String power = json['power'] ?? 'N/A';
        final List<Map<String, String>> pairedDevices =
            (json['paired_devices'] as List)
                .map((device) => Map<String, String>.from(device))
                .toList();

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $name', style: theme.bodyMedium),
              Text('Alias: $alias', style: theme.bodyMedium),
              Text('Address: $addr', style: theme.bodyMedium),
              Text('Power: $power', style: theme.bodyMedium),
              const SizedBox(height: 10),
              Text(
                'Paired Devices:',
                style: theme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ...pairedDevices.map((device) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: device.entries.map((entry) {
                      return Text(
                        '${entry.key}: ${entry.value}',
                        style: theme.bodyMedium,
                      );
                    }).toList(),
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
