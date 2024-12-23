import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';
import 'package:wlanpi_mobile/json_widget_builder.dart';

class ReachabilityWidget extends StatelessWidget {
  const ReachabilityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return EndpointDataFetcher(
      endpoint: "/api/v1/utils/reachability",
      method: "GET",
      builder: (context, json) {
        final String pingGoogle = json['Ping Google'] ?? 'N/A';
        final String browseGoogle = json['Browse Google'] ?? 'N/A';
        final String pingGateway = json['Ping Gateway'] ?? 'N/A';
        final String dnsServer1Resolution =
            json['DNS Server 1 Resolution'] ?? 'N/A';
        final String dnsServer2Resolution =
            json['DNS Server 2 Resolution'] ?? 'N/A';
        final String dnsServer3Resolution =
            json['DNS Server 3 Resolution'] ?? 'N/A';
        final String arpingGateway = json['Arping Gateway'] ?? 'N/A';

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ping Google: $pingGoogle', style: theme.bodyMedium),
              Text('Browse Google: $browseGoogle', style: theme.bodyMedium),
              Text('Ping Gateway: $pingGateway', style: theme.bodyMedium),
              Text('DNS Server 1 Resolution: $dnsServer1Resolution',
                  style: theme.bodyMedium),
              Text('DNS Server 2 Resolution: $dnsServer2Resolution',
                  style: theme.bodyMedium),
              Text('DNS Server 3 Resolution: $dnsServer3Resolution',
                  style: theme.bodyMedium),
              Text('Arping Gateway: $arpingGateway', style: theme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}
