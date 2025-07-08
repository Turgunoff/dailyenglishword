import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? wordData;
  bool isLoading = true;
  late List<dynamic> words;
  late DateTime currentDate = DateTime.now();
  List<String> hints = [];
  String? randomHint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWordOfTheDay();
    _loadHints();
  }

  Future<void> _loadWordOfTheDay([DateTime? date]) async {
    final locale = Localizations.localeOf(context).languageCode;
    String assetPath = 'assets/words/words_uz.json';
    if (locale == 'ru') {
      assetPath = 'assets/words/words_ru.json';
    }
    final jsonStr = await rootBundle.loadString(assetPath);
    words = json.decode(jsonStr);
    final today = date ?? DateTime.now();
    final todayStr =
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    Map<String, dynamic>? found;
    for (final w in words) {
      if (w['date'] == todayStr) {
        found = w;
        break;
      }
    }
    setState(() {
      wordData = found ?? (words.isNotEmpty ? words.first : null);
      currentDate = today;
      isLoading = false;
    });
  }

  Future<void> _loadHints() async {
    final locale = Localizations.localeOf(context).languageCode;
    String assetPath = 'assets/hints/hints_uz.json';
    if (locale == 'ru') {
      assetPath = 'assets/hints/hints_ru.json';
    }
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> hintList = json.decode(jsonStr);
    setState(() {
      hints = List<String>.from(hintList);
      if (hints.isNotEmpty) {
        randomHint = (hints..shuffle()).first;
      } else {
        randomHint = null;
      }
    });
  }

  void _goToPreviousDay() {
    final prev = currentDate.subtract(const Duration(days: 1));
    _loadWordOfTheDay(prev);
  }

  void _goToNextDay() {
    final next = currentDate.add(const Duration(days: 1));
    final nextStr =
        "${next.year.toString().padLeft(4, '0')}-${next.month.toString().padLeft(2, '0')}-${next.day.toString().padLeft(2, '0')}";
    final hasNext = words.any((w) => w['date'] == nextStr);
    if (hasNext) {
      _loadWordOfTheDay(next);
    }
  }

  String getLocalizedDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'uz') {
      // Example: 2025-yil 8-iyul, Seshanba
      final months = [
        '',
        'yanvar',
        'fevral',
        'mart',
        'aprel',
        'may',
        'iyun',
        'iyul',
        'avgust',
        'sentabr',
        'oktabr',
        'noyabr',
        'dekabr',
      ];
      final weekdays = [
        '',
        'Dushanba',
        'Seshanba',
        'Chorshanba',
        'Payshanba',
        'Juma',
        'Shanba',
        'Yakshanba',
      ];
      return '${date.year}-yil ${date.day}-${months[date.month]}, ${weekdays[date.weekday]}';
    } else if (locale == 'ru') {
      // Example: Вторник, 8 июля 2025 г.
      final ruLocale = 'ru_RU';
      final formatter = DateFormat('EEEE, d MMMM y  г.', ruLocale);
      String formatted = formatter.format(date);
      // Capitalize first letter
      return formatted[0].toUpperCase() + formatted.substring(1);
    } else {
      // Fallback to English
      return DateFormat('yMMMMd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final fadedTextColor =
        textColor?.withOpacity(0.6) ??
        (isDark ? Colors.white70 : Colors.black54);
    final boxColor = isDark
        ? colorScheme.surfaceVariant
        : const Color(0xFFF6F6F6);
    final borderColor = dividerColor;
    final iconColor = colorScheme.primary;

    final today = DateTime.now();
    final isToday =
        currentDate.year == today.year &&
        currentDate.month == today.month &&
        currentDate.day == today.day;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 0, // Hide the default AppBar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wordData == null
          ? Center(
              child: Text(
                'Word not found for this date',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      getLocalizedDate(currentDate, context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: fadedTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      randomHint ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fadedTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wordData!["word"] ?? '',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(
                                isDark ? 0.15 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              wordData!["pos"] ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            wordData!["translation"] ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: dividerColor),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: boxColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              wordData!["example"] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: fadedTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goToPreviousDay,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: borderColor),
                              foregroundColor: textColor,
                              textStyle: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 6),
                                Text(loc.yesterday),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isToday ? null : _goToNextDay,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: borderColor),
                              foregroundColor: textColor,
                              textStyle: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(loc.tomorrow),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: iconColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
