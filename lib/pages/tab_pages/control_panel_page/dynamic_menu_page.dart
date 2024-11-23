import 'package:wlanpi_mobile/pages/tab_pages/control_panel_page/retractable_card.dart';
import 'package:wlanpi_mobile/pages/tab_pages/control_panel_page/control_panel_page_widget.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicMenuPage extends StatefulWidget {
  final List<MenuItem> menuItems;

  const DynamicMenuPage({super.key, required this.menuItems});

  @override
  _DynamicMenuPageState createState() => _DynamicMenuPageState();
}

class _DynamicMenuPageState extends State<DynamicMenuPage> {
  List<MenuItem> currentMenu = [];
  List<List<MenuItem>> menuHistory = [];
  List<String> menuTitleHistory = [];

  @override
  void initState() {
    super.initState();
    currentMenu = widget.menuItems;
  }

  void onItemTap(MenuItem item) {
    if (item.subItems != null) {
      setState(() {
        menuHistory.add(currentMenu);
        menuTitleHistory.add(item.title);
        currentMenu = item.subItems!;
      });
    } else if (item.action != null) {
      item.onPressed!(context);
    }
  }

  void onBack() {
    if (menuHistory.isNotEmpty) {
      setState(() {
        currentMenu = menuHistory.removeLast();
        menuTitleHistory.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (menuHistory.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  Text(
                      menuTitleHistory.isNotEmpty ? menuTitleHistory.last : ''),
                ],
              ),
            Expanded(
              child: ListView.builder(
                itemCount: currentMenu.length,
                itemBuilder: (context, index) {
                  final item = currentMenu[index];
                  return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1),
                      ),
                      child: item.action == null
                          ? ListTile(
                              title: Text(
                                item.title,
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyLargeFamily),
                                    ),
                              ),
                              onTap: () => onItemTap(item),
                              trailing: item.onPressed == null
                                  ? Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    )
                                  : null,
                            )
                          : RetractableCard(
                              title: item.title, fetchContent: item.action!));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
