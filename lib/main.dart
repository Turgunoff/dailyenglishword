import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔔 Theme notifier — Global
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('uz'));
final ValueNotifier<Key> appKeyNotifier = ValueNotifier(const ValueKey('app'));

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 🛠️ Always include
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _loadInitialThemeAndLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final lang = prefs.getString('appLanguage') ?? "O'zbekcha";
    if (lang == "Русский") {
      localeNotifier.value = const Locale('ru');
    } else {
      localeNotifier.value = const Locale('uz');
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadInitialThemeAndLocale(); // Load saved theme and language
    return ValueListenableBuilder<Key>(
      valueListenable: appKeyNotifier,
      builder: (context, appKey, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            return ValueListenableBuilder<Locale>(
              valueListenable: localeNotifier,
              builder: (context, currentLocale, _) {
                return MaterialApp(
                  key: appKey,
                  debugShowCheckedModeBanner: false,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  theme: appLightTheme,
                  darkTheme: appDarkTheme,
                  themeMode: currentMode,
                  locale: currentLocale,
                  home: const MainScreen(),
                  supportedLocales: const [
                    Locale('uz'),
                    Locale('ru'),
                    Locale('en'),
                  ],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: (locale, supportedLocales) {
                    if (locale == null) return const Locale('uz');
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                    return const Locale('uz');
                  },
                );
              },
            );
          },
        );
      },
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
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_copy),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.clock_copy),
            label: AppLocalizations.of(context)!.history,
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting_2_copy),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
