import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RetractableCard extends StatefulWidget {
  final String title;
  final Widget jsonWidget;

  const RetractableCard({
    super.key,
    required this.title,
    required this.jsonWidget,
  });

  @override
  _RetractableCardState createState() => _RetractableCardState();
}

class _RetractableCardState extends State<RetractableCard> {
  bool _isExpanded = false;
  late Widget _json_widget;

  @override
  void initState() {
    super.initState();
    _json_widget = widget.jsonWidget;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);

    return Column(
      children: [
        ListTile(
          title: Text(
            widget.title,
            style: theme.bodyLarge.override(
              fontFamily: theme.bodyLargeFamily,
              letterSpacing: 0.0,
              useGoogleFonts:
                  GoogleFonts.asMap().containsKey(theme.bodyLargeFamily),
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _json_widget,
          ),
      ],
    );
  }
}
