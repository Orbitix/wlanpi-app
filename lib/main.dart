import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/pages/apps_page/apps_page_widget.dart';
import 'package:wlanpi_mobile/pages/control_panel_page/control_panel_page_widget.dart';
import 'package:wlanpi_mobile/pages/stats_page/stats_page_widget.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';
import 'theme/theme.dart';
import 'utils/flutter_flow_util.dart';
import 'pages/pi_page/pi_page_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await CustomTheme.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SharedMethodsProvider()),
        ChangeNotifierProvider(create: (_) => AppStateNotifier.instance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = CustomTheme.themeMode;

  @override
  void initState() {
    super.initState();
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        CustomTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WLAN Pi',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    PiPageWidget(),
    StatsPageWidget(),
    AppsPageWidget(),
    ControlPanelPageWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: theme.secondaryBackground,
        indicatorColor: theme.accent1,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(CupertinoIcons.tv, color: theme.primaryText),
            selectedIcon:
                Icon(CupertinoIcons.tv_fill, color: theme.primaryText),
            label: 'My Pi',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.graph_square, color: theme.primaryText),
            selectedIcon: Icon(CupertinoIcons.graph_square_fill,
                color: theme.primaryText),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.plus_square_on_square,
                color: theme.primaryText),
            selectedIcon: Icon(CupertinoIcons.plus_square_fill_on_square_fill,
                color: theme.primaryText),
            label: 'Apps',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.hammer, color: theme.primaryText),
            selectedIcon:
                Icon(CupertinoIcons.hammer_fill, color: theme.primaryText),
            label: 'Control Panel',
          ),
        ],
      ),
    );
  }
}
