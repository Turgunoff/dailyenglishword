import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool dailyReminder = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String appLanguage = "O'zbekcha";

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      dailyReminder = prefs.getBool('dailyReminder') ?? false;
      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;
      reminderTime = TimeOfDay(hour: hour, minute: minute);
      appLanguage = prefs.getString('appLanguage') ?? "O'zbekcha";
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('dailyReminder', dailyReminder);
    await prefs.setInt('reminderHour', reminderTime.hour);
    await prefs.setInt('reminderMinute', reminderTime.minute);
    await prefs.setString('appLanguage', appLanguage);
  }

  void _onDarkModeChanged(bool v) async {
    setState(() => isDarkMode = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _onLanguageChanged() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text("O'zbekcha"),
              onTap: () => Navigator.pop(context, "O'zbekcha"),
              selected: appLanguage == "O'zbekcha",
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text("Русский"),
              onTap: () => Navigator.pop(context, "Русский"),
              selected: appLanguage == "Русский",
            ),
          ],
        );
      },
    );
    if (selected != null && selected != appLanguage) {
      setState(() => appLanguage = selected);
      _savePrefs();
      // Update global locale
      if (selected == "O'zbekcha") {
        localeNotifier.value = const Locale('uz');
      } else if (selected == "Русский") {
        localeNotifier.value = const Locale('ru');
      }
      // Force full app rebuild
      appKeyNotifier.value = ValueKey(DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final iconColor = colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color;
    final sectionTitleColor =
        theme.textTheme.labelMedium?.color?.withOpacity(0.7) ??
        (isDark ? Colors.white70 : Colors.black54);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          loc.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SizedBox(height: 8),
          Text(
            loc.appearance,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: sectionTitleColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Iconsax.moon_copy, color: iconColor),
                  title: Text(
                    // "Qorong'i rejim",
                    loc.darkMode ?? "Dark Mode",
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: CupertinoSwitch(
                    value: isDarkMode,
                    onChanged: _onDarkModeChanged,
                    activeColor: iconColor,
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: Icon(Iconsax.language_circle_copy, color: iconColor),
                  title: Text(
                    loc.appLanguage,
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appLanguage,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3_copy, color: iconColor),
                    ],
                  ),
                  onTap: _onLanguageChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.about,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: sectionTitleColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Iconsax.info_circle_copy, color: iconColor),
                  title: Text(loc.aboutApp, style: theme.textTheme.bodyLarge),
                  trailing: Icon(Iconsax.arrow_right_3_copy, color: iconColor),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(loc.aboutApp),
                        content: Text(
                          Localizations.localeOf(context).languageCode == 'ru'
                              ? 'Daily English Word — каждый день новое английское слово и пример предложения. Версия: 1.0.0'
                              : 'Daily English Word — har kuni yangi inglizcha so’z va misol jumla. Versiya: 1.0.0',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: dividerColor),
                ListTile(
                  leading: Icon(Iconsax.star_copy, color: iconColor),
                  title: Text(loc.rateOnPlay, style: theme.textTheme.bodyLarge),
                  trailing: Icon(Iconsax.arrow_right_3_copy, color: iconColor),
                  onTap: () async {
                    const url =
                        'https://play.google.com/store/apps/details?id=com.fridaysnights.dailyenglishword';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
