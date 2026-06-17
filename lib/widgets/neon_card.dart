import 'package:flutter/material.dart';

import '../models/app_preferences.dart';

class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? AppPreferencesScope.of(context).layoutDensity.cardPadding,
        child: child,
      ),
    );
  }
}
