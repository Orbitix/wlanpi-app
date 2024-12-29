import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_widgets.dart';
import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:wlanpi_mobile/widgets/connection_options_bottom_sheet.dart';

class NotConnectedWidget extends StatelessWidget {
  const NotConnectedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: theme.primary,
            size: 50,
          ),
          SizedBox(height: 16),
          Text(
            "No Pi connected",
            style: theme.titleMedium,
          ),
          SizedBox(height: 16),
          FFButtonWidget(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const ConnectionOptionsBottomSheet(),
              );
            },
            text: 'Connect',
            options: FFButtonOptions(
              width: 200,
              height: 50.0,
              color: theme.accent1,
              textStyle: theme.titleSmall,
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ],
      ),
    );
  }
}
