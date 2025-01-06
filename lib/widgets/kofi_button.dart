import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wlanpi_mobile/theme/theme.dart';

class KoFiButton extends StatelessWidget {
  final String kofiName;
  final String text;

  const KoFiButton({
    super.key,
    required this.kofiName,
    this.text = "Support me on Ko-fi", // Default text
  });

  Future<void> _launchKoFi(String kofiName) async {
    final koFiUrl = "https://ko-fi.com/$kofiName";
    if (await canLaunchUrlString(koFiUrl)) {
      await launchUrlString(koFiUrl);
    } else {
      throw "Could not launch $koFiUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);

    return GestureDetector(
      onTap: () {
        _launchKoFi(kofiName);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.alternate, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/kofi/kofi_symbol.png', // Ko-fi logo
                    fit: BoxFit.contain,
                    width: 24,
                    alignment: const Alignment(0.0, 0.0),
                  ),
                  SizedBox(width: 10.0),
                  Text(text, style: theme.bodyLarge),
                ],
              ),
              Icon(Icons.open_in_new_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
