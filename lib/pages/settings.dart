import '../theme/theme.dart';
import '../utils/flutter_flow_util.dart';
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
  final TextEditingController _LANController = TextEditingController();

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
      _LANController.text = prefs.getString('LANIpAddress')!;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('otgIpAddress', _otgController.text);
    await prefs.setString('bluetoothIpAddress', _bluetoothController.text);
    await prefs.setString('LANIpAddress', _LANController.text);

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
    final theme = CustomTheme.of(context); // Access FlutterFlow theme
    final typography = theme.typography; // Access typography styles

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
            border: Border(top: BorderSide(color: theme.alternate, width: 2.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Change here
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
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
                        TextField(
                          controller: _LANController,
                          cursorColor: theme.primary,
                          decoration: InputDecoration(
                            labelText: 'LAN IP Address',
                            labelStyle: typography.bodyLarge
                                .copyWith(color: theme.primaryText),
                            hintText: 'Enter LAN IP',
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
