import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/widgets/not_connected_widget.dart';

class NotConnectedOverlay extends StatelessWidget {
  const NotConnectedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        NotConnectedWidget()
      ],
    );
  }
}
