import 'package:flutter/material.dart';

/// App-wide display choices used to make the mobile layout easier to read at
/// the track. These are intentionally simple while the app is still in alpha.
enum AppTextSize {
  normal,
  large,
  extraLarge;

  String get label => switch (this) {
        AppTextSize.normal => 'Normal',
        AppTextSize.large => 'Large +2',
        AppTextSize.extraLarge => 'Extra large +4',
      };

  String get description => switch (this) {
        AppTextSize.normal => 'Current app text size',
        AppTextSize.large => 'Roughly two points larger',
        AppTextSize.extraLarge => 'Roughly four points larger',
      };

  /// TextScaler is proportional, so +2/+4 are approximated from the normal
  /// 16 px body text size while still scaling headings and buttons together.
  double get scale => switch (this) {
        AppTextSize.normal => 1.00,
        AppTextSize.large => 1.125,
        AppTextSize.extraLarge => 1.25,
      };
}

enum LayoutDensity {
  comfortable,
  compact,
  fullWidth;

  String get label => switch (this) {
        LayoutDensity.comfortable => 'Comfortable',
        LayoutDensity.compact => 'Compact',
        LayoutDensity.fullWidth => 'Full width',
      };

  String get description => switch (this) {
        LayoutDensity.comfortable => 'Original spacing',
        LayoutDensity.compact => 'Less outside and card padding',
        LayoutDensity.fullWidth => 'Minimum margins for phone screens',
      };

  EdgeInsets get screenPadding => switch (this) {
        LayoutDensity.comfortable => const EdgeInsets.all(14),
        LayoutDensity.compact => const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        LayoutDensity.fullWidth => const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      };

  EdgeInsets get cardPadding => switch (this) {
        LayoutDensity.comfortable => const EdgeInsets.all(16),
        LayoutDensity.compact => const EdgeInsets.all(10),
        LayoutDensity.fullWidth => const EdgeInsets.all(8),
      };
}

class AppPreferences {
  const AppPreferences({
    required this.textSize,
    required this.layoutDensity,
  });

  final AppTextSize textSize;
  final LayoutDensity layoutDensity;

  static const defaults = AppPreferences(
    textSize: AppTextSize.normal,
    layoutDensity: LayoutDensity.compact,
  );

  Map<String, dynamic> toJson() => {
        'textSize': textSize.name,
        'layoutDensity': layoutDensity.name,
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    AppTextSize parseTextSize() {
      final name = json['textSize'] as String?;
      return AppTextSize.values.firstWhere(
        (value) => value.name == name,
        orElse: () => AppPreferences.defaults.textSize,
      );
    }

    LayoutDensity parseDensity() {
      final name = json['layoutDensity'] as String?;
      return LayoutDensity.values.firstWhere(
        (value) => value.name == name,
        orElse: () => AppPreferences.defaults.layoutDensity,
      );
    }

    return AppPreferences(
      textSize: parseTextSize(),
      layoutDensity: parseDensity(),
    );
  }

  AppPreferences copyWith({
    AppTextSize? textSize,
    LayoutDensity? layoutDensity,
  }) {
    return AppPreferences(
      textSize: textSize ?? this.textSize,
      layoutDensity: layoutDensity ?? this.layoutDensity,
    );
  }
}

class AppPreferencesScope extends InheritedWidget {
  const AppPreferencesScope({
    super.key,
    required this.preferences,
    required super.child,
  });

  final AppPreferences preferences;

  static AppPreferences of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppPreferencesScope>()?.preferences ?? AppPreferences.defaults;
  }

  @override
  bool updateShouldNotify(AppPreferencesScope oldWidget) => preferences != oldWidget.preferences;
}
