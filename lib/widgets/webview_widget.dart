import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wlanpi_mobile/theme/theme.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const WebViewPage({super.key, required this.title, required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  bool isLoading = true; // Track the loading state
  int loadingPercentage = 0; // Track the loading progress percentage

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController and set up navigation delegate
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress; // Update progress
            });
            debugPrint("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true; // Show loading indicator
              loadingPercentage = 0; // Reset loading progress
            });
            debugPrint("Page started loading: $url");
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false; // Hide loading indicator
              loadingPercentage = 100; // Set progress to 100%
            });
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
      ..loadRequest(Uri.parse(widget.url)); // Load the URL passed to the widget
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final theme = CustomTheme.of(context);
    controller.setBackgroundColor(theme.primaryBackground);
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
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller), // The WebView
          if (isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: theme.alternate, width: 2.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Replace spinner with LinearProgressIndicator
                        LinearProgressIndicator(
                          value: loadingPercentage / 100.0, // Update progress
                          color: theme.primary, // Progress bar color
                          backgroundColor: theme.alternate,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Loading, please wait... ($loadingPercentage%)",
                          style: theme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "This may take 10s to a few minutes depending on connection speed and Pi performance.",
                          style: theme.bodyLarge
                              .copyWith(color: theme.secondaryText),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
