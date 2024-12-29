import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:wlanpi_mobile/utils/json_widget_builder.dart';

class UfwPortsWidget extends StatelessWidget {
  const UfwPortsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);

    return EndpointDataFetcher(
      endpoint: "/api/v1/utils/ufw",
      method: "GET",
      builder: (context, json) {
        final String status = json['status'] ?? 'N/A';
        final List<Map<String, dynamic>> ports = (json['ports'] as List)
            .map((device) => Map<String, String>.from(device))
            .toList();

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "UFW Status: $status",
                style: theme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Text('To',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Action',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('From',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ...ports.map((ufwInterface) {
                    final action = ufwInterface["Action"].toString();
                    final actionColor =
                        action == "ALLOW" ? Colors.green : Colors.red;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(ufwInterface["To"].toString(),
                              style: theme.bodyMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(action,
                              style: theme.bodyMedium
                                  .copyWith(color: actionColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(ufwInterface["From"].toString(),
                              style: theme.bodyMedium),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
