import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wlanpi_mobile/theme/theme.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  WebViewPage({super.key, required this.title, required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            debugPrint("Page started loading: $url");
          },
          onPageFinished: (String url) {
            debugPrint("Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Web resource error: $error");
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint("Navigation request: ${request.url}");
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // Use the url passed to the widget
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          widget.title,
          style: theme.titleLarge,
        ), // Use the title passed to the widget
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
