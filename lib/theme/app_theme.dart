import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF09000F);
  static const Color panel = Color(0xFF111018);
  static const Color panel2 = Color(0xFF1A1224);
  static const Color hotPink = Color(0xFFDD1081);
  static const Color neonYellow = Color(0xFFDFDC15);
  static const Color electricBlue = Color(0xFF00B7FF);
  static const Color purple = Color(0xFF5122B7);
  static const Color magentaGlow = Color(0xFFCF3DCC);
  static const Color white = Color(0xFFF5F5F5);
  static const Color mutedText = Color(0xFFC7BFD2);

  static ThemeData get darkNeonTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: hotPink,
        brightness: Brightness.dark,
        primary: hotPink,
        secondary: electricBlue,
        tertiary: neonYellow,
        surface: panel,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: panel,
        foregroundColor: white,
        centerTitle: false,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: panel),
      cardTheme: CardThemeData(
        color: panel.withOpacity(0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: hotPink.withOpacity(0.35), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.35),
        labelStyle: const TextStyle(color: mutedText),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: electricBlue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: white.withOpacity(0.18)),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: white,
        displayColor: white,
      ),
    );
  }
}
