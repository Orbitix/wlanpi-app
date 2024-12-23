import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';
import 'package:wlanpi_mobile/json_widget_builder.dart';

class NetworkInfoWidget extends StatelessWidget {
  const NetworkInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return EndpointDataFetcher(
      endpoint: "/api/v1/network/info",
      method: "GET",
      builder: (context, json) {
        final Map<String, dynamic> interfaces = json['interfaces'] ?? {};
        final Map<String, dynamic> wlanInterfaces =
            json['wlan_interfaces'] ?? {};
        final Map<String, dynamic> eth0IpconfigInfo =
            json['eth0_ipconfig_info'] ?? {};
        final Map<String, dynamic> vlanInfo = json['vlan_info'] ?? {};
        final Map<String, dynamic> lldpNeighbourInfo =
            json['lldp_neighbour_info'] ?? {};
        final Map<String, dynamic> cdpNeighbourInfo =
            json['cdp_neighbour_info'] ?? {};
        final Map<String, dynamic> publicIp = json['public_ip'] ?? {};

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   "Interfaces",
              //   style: theme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Text('Interface',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Status',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('IP',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ...interfaces.entries.map((entry) {
                    final interfaceName = entry.key;
                    final interfaceData = entry.value as Map<String, dynamic>;
                    final status = interfaceData['status'] ?? 'N/A';
                    final statusColor =
                        status == "UP" ? Colors.green : Colors.red;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(interfaceName, style: theme.bodyMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(status,
                              style: theme.bodyMedium
                                  .copyWith(color: statusColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(interfaceData['ip'] ?? 'N/A',
                              style: theme.bodyMedium),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Text('Wlan Interface',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Driver',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Address',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Modes',
                          style: theme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ...wlanInterfaces.entries.map((entry) {
                    final interfaceName = entry.key;
                    final interfaceData = entry.value as Map<String, dynamic>;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(interfaceName, style: theme.bodyMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(interfaceData['driver'] ?? 'N/A',
                              style: theme.bodyMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(interfaceData['addr'] ?? 'N/A',
                              style: theme.bodyMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                              interfaceData['mode'].map((mode) {
                                return mode.toString();
                              }).join(', '),
                              style: theme.bodyMedium),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection('eth0 IP Config Info', eth0IpconfigInfo, theme),
              _buildSection('VLAN Info', vlanInfo, theme),
              _buildSection('LLDP Neighbour Info', lldpNeighbourInfo, theme),
              _buildSection('CDP Neighbour Info', cdpNeighbourInfo, theme),
              _buildSection('Public IP', publicIp, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      String title, Map<String, dynamic> data, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}:',
                    style:
                        theme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (entry.value is Map<String, dynamic>)
                    ..._buildNestedSection(entry.value, theme)
                  else if (entry.value is List)
                    ..._buildListSection(entry.value, theme)
                  else
                    Text(
                      entry.value.toString(),
                      style: theme.bodyMedium,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildNestedSection(
      Map<String, dynamic> data, FlutterFlowTheme theme) {
    return data.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key}: ',
              style: theme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                entry.value.toString(),
                style: theme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildListSection(List data, FlutterFlowTheme theme) {
    return data.map((item) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
        child: Text(
          item.toString(),
          style: theme.bodyMedium,
        ),
      );
    }).toList();
  }
}
