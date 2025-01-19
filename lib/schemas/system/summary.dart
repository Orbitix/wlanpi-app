import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:wlanpi_mobile/utils/json_widget_builder.dart';

class SystemSummaryWidget extends StatelessWidget {
  const SystemSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);

    return EndpointDataFetcher(
      endpoint: "/api/v1/system/device/info",
      method: "GET",
      builder: (context, json) {
        final String model = json['model'] ?? 'N/A';
        final String hostname = json['hostname'] ?? 'N/A';
        final String name = json['name'] ?? 'N/A';
        final String softwareVersion = json['software_version'] ?? 'N/A';
        final String mode = json['mode'] ?? 'N/A';

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Model:  ',
                      style: theme.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: model,
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hostname:  ',
                      style: theme.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: hostname,
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Name:  ',
                      style: theme.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: name,
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'WLAN Pi OS Version:  ',
                      style: theme.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: softwareVersion,
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mode:  ',
                      style: theme.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: mode,
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
