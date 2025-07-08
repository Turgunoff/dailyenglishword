import 'package:dailyenglishword/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> words = [];
  List<dynamic> filteredWords = [];
  bool isLoading = true;
  String search = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final locale = Localizations.localeOf(context).languageCode;
    String assetPath = 'assets/words/words_uz.json';
    if (locale == 'ru') {
      assetPath = 'assets/words/words_ru.json';
    }
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> loadedWords = json.decode(jsonStr);
    final today = DateTime.now();
    final filtered = loadedWords.where((w) {
      final wordDate = DateTime.parse(w['date']);
      return !wordDate.isAfter(DateTime(today.year, today.month, today.day));
    }).toList();
    setState(() {
      words = filtered;
      filteredWords = filtered;
      isLoading = false;
    });
  }

  void _onSearch(String value) {
    setState(() {
      search = value;
      filteredWords = words
          .where(
            (w) => w['word'].toString().toLowerCase().contains(
              value.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearch('');
  }

  void _showExampleModal(BuildContext context, Map<String, dynamic> word) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word['word'],
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                word['example'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                word['translation'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getLocalizedDate(String dateStr, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(dateStr);
    if (locale == 'uz') {
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
      return '${date.day}-${months[date.month]}, ${date.year}';
    } else if (locale == 'ru') {
      final ruLocale = 'ru_RU';
      final formatter = DateFormat('d MMMM, y', ruLocale);
      String formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } else {
      return DateFormat('yMMMMd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final fadedTextColor = textColor?.withOpacity(0.6);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: fadedTextColor),
                      hintText: loc.searchWords,
                      filled: true,
                      fillColor: cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: search.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: fadedTextColor),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    itemCount: filteredWords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final w = filteredWords[i];
                      return Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showExampleModal(context, w),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        w['word'],
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        getLocalizedDate(w['date'], context),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: fadedTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: fadedTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
