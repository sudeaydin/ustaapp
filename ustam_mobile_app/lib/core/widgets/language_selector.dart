import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

class LanguageSelector extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const LanguageSelector({
    Key? key,
    this.size = 24.0,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    final languages = [
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    ];

    final currentLanguage = languages.firstWhere(
      (lang) => lang['code'] == locale.languageCode,
      orElse: () => languages.first,
    );

    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLanguage['flag']!,
            style: TextStyle(fontSize: size),
          ),
          const SizedBox(width: 4),
          Text(
            currentLanguage['code']!.toUpperCase(),
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
      tooltip: 'language'.tr(locale),
      onSelected: (String languageCode) {
        final newLocale = languageCode == 'tr' 
            ? const Locale('tr', 'TR')
            : const Locale('en', 'US');
        languageNotifier.setLanguage(newLocale);
      },
      itemBuilder: (BuildContext context) => languages.map((language) {
        final isSelected = language['code'] == locale.languageCode;
        return PopupMenuItem<String>(
          value: language['code'],
          child: Row(
            children: [
              Text(
                language['flag']!,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  language['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 16),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SimpleLanguageSelector extends ConsumerWidget {
  const SimpleLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return IconButton(
      icon: Text(
        locale.languageCode == 'tr' ? '🇹🇷' : '🇺🇸',
        style: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        final newLocale = locale.languageCode == 'tr'
            ? const Locale('en', 'US')
            : const Locale('tr', 'TR');
        languageNotifier.setLanguage(newLocale);
      },
      tooltip: locale.languageCode == 'tr' ? 'Switch to English' : 'Türkçe\'ye geç',
    );
  }
}