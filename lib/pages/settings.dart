import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _otgController = TextEditingController();
  final TextEditingController _bluetoothController = TextEditingController();

  String _buttonText = 'Save Settings';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _otgController.text = prefs.getString('otgIpAddress')!;
      _bluetoothController.text = prefs.getString('bluetoothIpAddress')!;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('otgIpAddress', _otgController.text);
    await prefs.setString('bluetoothIpAddress', _bluetoothController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        duration: Duration(seconds: 2), // Duration to show the SnackBar
      ),
    );

    // Change button text to "Saved"
    setState(() {
      _buttonText = 'Saved!';
    });

    // Reset button text after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _buttonText = 'Save Settings';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context); // Access FlutterFlow theme
    final typography = theme.typography; // Access typography styles

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text('Settings', style: typography.titleLarge),
        backgroundColor: theme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Change here
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.alternate,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        'Network Settings',
                        style: typography.titleLarge
                            .copyWith(color: theme.primaryText),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Change here
                      children: [
                        TextField(
                          controller: _otgController,
                          cursorColor: theme.primary,
                          decoration: InputDecoration(
                            labelText: 'USB OTG IP Address',
                            labelStyle: typography.bodyLarge
                                .copyWith(color: theme.primaryText),
                            hintText: 'Enter OTG IP',
                            hintStyle: typography.bodySmall,
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Spacing
                        TextField(
                          controller: _bluetoothController,
                          cursorColor: theme.primary,
                          decoration: InputDecoration(
                            labelText: 'Bluetooth IP Address',
                            labelStyle: typography.bodyLarge
                                .copyWith(color: theme.primaryText),
                            hintText: 'Enter Bluetooth IP',
                            hintStyle: typography.bodySmall,
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Spacing
                        ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: Icon(Icons.save, color: theme.primaryText),
                          label: Text(
                            _buttonText,
                            style: typography.bodyMedium
                                .copyWith(color: theme.primaryText),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                theme.primary, // Button background color
                            foregroundColor:
                                theme.primaryText, // Button text color
                          ),
                        ),
                      ].divide(const SizedBox(height: 5.0)),
                    ),
                  ),
                ),
              ].divide(const SizedBox(height: 10.0)),
            ),
          ),
        ),
      ),
    );
  }
}
