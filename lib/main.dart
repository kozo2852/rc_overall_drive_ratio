import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RcOverallDriveRatioApp());
}

class RcOverallDriveRatioApp extends StatelessWidget {
  const RcOverallDriveRatioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RC Overall Drive Ratio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkNeonTheme,
      home: const AppShell(),
    );
  }
}
