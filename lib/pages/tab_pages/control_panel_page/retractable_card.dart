import 'package:flutter/material.dart';
import 'package:wlanpi_mobile/flutter_flow/flutter_flow_theme.dart';

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
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      // margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
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
      ),
    );
  }
}
