import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

/// A reusable theme toggle button for the app bar.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  void _showThemeMenu(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Theme Selection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...[ThemeMode.system, ThemeMode.light, ThemeMode.dark].map(
                (mode) => ListTile(
                  leading: Icon(ThemeModeNotifier.getThemeIcon(mode)),
                  title: Text(ThemeModeNotifier.getThemeName(mode)),
                  trailing: currentMode == mode
                      ? const Icon(Icons.check, color: Colors.teal)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return IconButton(
      icon: Icon(ThemeModeNotifier.getThemeIcon(themeMode)),
      tooltip: 'Toggle theme',
      onPressed: () => _showThemeMenu(context, ref),
    );
  }
}
