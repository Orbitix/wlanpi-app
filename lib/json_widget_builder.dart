import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';
import 'package:wlanpi_mobile/network_handler.dart';

typedef JSONWidgetBuilder = Widget Function(
    BuildContext context, Map<String, dynamic> data);

class EndpointDataFetcher extends StatelessWidget {
  final String endpoint;
  final String method;
  final JSONWidgetBuilder builder;

  const EndpointDataFetcher({
    super.key,
    required this.endpoint,
    required this.method,
    required this.builder,
  });

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      final response =
          await NetworkHandler().requestEndpoint("31415", endpoint, method);
      return response;
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.containsKey('error')) {
          return Center(
              child:
                  Text('Error: ${snapshot.data?['error'] ?? 'Unknown error'}'));
        }

        return builder(context, snapshot.data!);
      },
    );
  }
}
