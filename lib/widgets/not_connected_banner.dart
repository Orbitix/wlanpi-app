import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_widgets.dart';
import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:wlanpi_mobile/utils/flutter_flow_util.dart';
import 'package:wlanpi_mobile/widgets/connection_options_bottom_sheet.dart';

class NotConnectedBanner extends StatelessWidget {
  const NotConnectedBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    return Container(
      width: double.infinity,
      color: theme.alternate,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Pi Connected',
            style: theme.bodyMedium,
          ),
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
              height: 30.0,
              color: theme.accent1,
              textStyle: theme.titleSmall,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ].divide(const SizedBox(width: 10.0)),
      ),
    );
  }
}
