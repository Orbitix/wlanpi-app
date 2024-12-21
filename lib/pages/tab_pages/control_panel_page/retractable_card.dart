import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RetractableCard extends StatefulWidget {
  final String title;
  final Future<String> Function() fetchContent;

  const RetractableCard(
      {super.key, required this.title, required this.fetchContent});

  @override
  _RetractableCardState createState() => _RetractableCardState();
}

class _RetractableCardState extends State<RetractableCard> {
  bool _isExpanded = false;
  String _content = "";
  bool _isLoading = true;

  void _loadContent(context) async {
    final content = await widget.fetchContent();
    setState(() {
      _content = content;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

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
            if (_isExpanded && _isLoading) {
              _loadContent(context); // Load content when expanded
            }
          },
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    color: FlutterFlowTheme.of(context).primary,
                  ))
                : Text(_content),
          ),
      ],
    );
  }
}
