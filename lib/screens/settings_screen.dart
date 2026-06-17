import 'package:flutter/material.dart';

import '../models/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  final AppPreferences preferences;
  final ValueChanged<AppPreferences> onPreferencesChanged;

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferencesScope.of(context);
    return ListView(
      padding: prefs.layoutDensity.screenPadding,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Display settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text(
                        'Use these options to test bigger text and tighter mobile spacing with alpha users.',
                        style: TextStyle(color: AppTheme.mutedText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Text size', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      for (final option in AppTextSize.values)
                        RadioListTile<AppTextSize>(
                          value: option,
                          groupValue: preferences.textSize,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(option.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(option.description),
                          onChanged: (value) {
                            if (value == null) return;
                            onPreferencesChanged(preferences.copyWith(textSize: value));
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Layout spacing', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      for (final option in LayoutDensity.values)
                        RadioListTile<LayoutDensity>(
                          value: option,
                          groupValue: preferences.layoutDensity,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(option.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(option.description),
                          onChanged: (value) {
                            if (value == null) return;
                            onPreferencesChanged(preferences.copyWith(layoutDensity: value));
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Alpha note', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.neonYellow)),
                      SizedBox(height: 6),
                      Text(
                        'Browser saves use localStorage on GitHub Pages. That means saved cars and settings should persist in the same browser, but they will not sync between devices yet.',
                        style: TextStyle(color: AppTheme.mutedText, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
