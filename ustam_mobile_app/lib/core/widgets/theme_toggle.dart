import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class ThemeToggle extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const ThemeToggle({
    Key? key,
    this.size = 24.0,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    final isDark = themeMode == ThemeMode.dark;
    final label = isDark 
        ? 'light_mode'.tr(locale)
        : 'dark_mode'.tr(locale);

    return PopupMenuButton<ThemeMode>(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        size: size,
        color: Theme.of(context).iconTheme.color,
      ),
      tooltip: 'theme'.tr(locale),
      onSelected: (ThemeMode mode) {
        themeNotifier.setTheme(mode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.light,
          child: Row(
            children: [
              const Icon(Icons.light_mode),
              const SizedBox(width: 8),
              const Text('light_mode'.tr(locale)),
              if (themeMode == ThemeMode.light)
                const Padding(
      padding: EdgeInsets.only(left: 8),
                  child: const Icon(Icons.check, size: 16),
                ),
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          child: Row(
            children: [
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
              const Text('dark_mode'.tr(locale)),
              if (themeMode == ThemeMode.dark)
                const Padding(
      padding: EdgeInsets.only(left: 8),
                  child: const Icon(Icons.check, size: 16),
                ),
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.system,
          child: Row(
            children: [
              const Icon(Icons.settings),
              const SizedBox(width: 8),
              const Text('system_mode'.tr(locale)),
              if (themeMode == ThemeMode.system)
                const Padding(
      padding: EdgeInsets.only(left: 8),
                  child: const Icon(Icons.check, size: 16),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SimpleThemeToggle extends ConsumerWidget {
  const SimpleThemeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: () {
        themeNotifier.setTheme(
          isDark ? ThemeMode.light : ThemeMode.dark,
        );
      },
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
    );
  }
}