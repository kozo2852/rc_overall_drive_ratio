import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/gear_setup.dart';
import '../services/gear_ratio_service.dart';
import '../theme/app_theme.dart';
import 'assistant_screen.dart';
import 'calculator_screen.dart';
import 'tuning_guide_screen.dart';

enum AppScreen { calculator, assistant, guide }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppScreen _screen = AppScreen.calculator;

  final TextEditingController pinionController = TextEditingController(text: '24');
  final TextEditingController spurController = TextEditingController(text: '78');
  final TextEditingController transmissionController = TextEditingController(text: '2.60');
  final TextEditingController tireDiameterController = TextEditingController(text: '2.65');
  final TextEditingController tireCircumferenceController = TextEditingController();

  TireUnit tireUnit = TireUnit.inches;
  bool _updatingTireFields = false;

  @override
  void initState() {
    super.initState();
    tireCircumferenceController.text = GearRatioService
        .diameterToCircumference(2.65)
        .toStringAsFixed(3);
    pinionController.addListener(_gearChanged);
    spurController.addListener(_gearChanged);
    transmissionController.addListener(_gearChanged);
    tireDiameterController.addListener(_diameterChanged);
    tireCircumferenceController.addListener(_circumferenceChanged);
  }

  @override
  void dispose() {
    pinionController.dispose();
    spurController.dispose();
    transmissionController.dispose();
    tireDiameterController.dispose();
    tireCircumferenceController.dispose();
    super.dispose();
  }

  void _gearChanged() => setState(() {});

  GearSetup? get baselineSetup {
    final pinion = int.tryParse(pinionController.text.trim());
    final spur = int.tryParse(spurController.text.trim());
    final transmission = double.tryParse(transmissionController.text.trim());
    if (pinion == null || spur == null || transmission == null) return null;
    if (pinion <= 0 || spur <= 0 || transmission <= 0) return null;
    return GearSetup(pinion: pinion, spur: spur, transmissionRatio: transmission);
  }

  double? get tireCircumference {
    final value = double.tryParse(tireCircumferenceController.text.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  void _diameterChanged() {
    if (_updatingTireFields) return;
    final diameter = double.tryParse(tireDiameterController.text.trim());
    _updatingTireFields = true;
    if (diameter == null || diameter <= 0) {
      tireCircumferenceController.clear();
    } else {
      tireCircumferenceController.text = GearRatioService
          .diameterToCircumference(diameter)
          .toStringAsFixed(tireUnit == TireUnit.inches ? 3 : 1);
    }
    _updatingTireFields = false;
    setState(() {});
  }

  void _circumferenceChanged() {
    if (_updatingTireFields) return;
    final circumference = double.tryParse(tireCircumferenceController.text.trim());
    _updatingTireFields = true;
    if (circumference == null || circumference <= 0) {
      tireDiameterController.clear();
    } else {
      tireDiameterController.text = GearRatioService
          .circumferenceToDiameter(circumference)
          .toStringAsFixed(tireUnit == TireUnit.inches ? 3 : 1);
    }
    _updatingTireFields = false;
    setState(() {});
  }

  void updateTireUnit(TireUnit newUnit) {
    if (newUnit == tireUnit) return;
    final multiplier = newUnit == TireUnit.millimeters ? 25.4 : 1 / 25.4;
    final diameter = double.tryParse(tireDiameterController.text.trim());
    final circumference = double.tryParse(tireCircumferenceController.text.trim());
    _updatingTireFields = true;
    if (diameter != null && diameter > 0) {
      tireDiameterController.text = (diameter * multiplier).toStringAsFixed(newUnit == TireUnit.inches ? 3 : 1);
    }
    if (circumference != null && circumference > 0) {
      tireCircumferenceController.text = (circumference * multiplier).toStringAsFixed(newUnit == TireUnit.inches ? 3 : 1);
    }
    _updatingTireFields = false;
    setState(() => tireUnit = newUnit);
  }

  void _goTo(AppScreen screen) {
    setState(() => _screen = screen);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_screen) {
      AppScreen.calculator => 'Calculator',
      AppScreen.assistant => 'Gear Change Assistant',
      AppScreen.guide => 'Tuning Guide',
    };

    final common = SharedSetupData(
      pinionController: pinionController,
      spurController: spurController,
      transmissionController: transmissionController,
      tireDiameterController: tireDiameterController,
      tireCircumferenceController: tireCircumferenceController,
      tireUnit: tireUnit,
      onTireUnitChanged: updateTireUnit,
      baselineSetup: baselineSetup,
      tireCircumference: tireCircumference,
    );

    final body = switch (_screen) {
      AppScreen.calculator => CalculatorScreen(shared: common),
      AppScreen.assistant => AssistantScreen(shared: common),
      AppScreen.guide => const TuningGuideScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.purple, AppTheme.panel]),
                ),
                child: const Text(
                  'RC Overall\nDrive Ratio',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              _DrawerItem(
                label: 'Calculator',
                icon: Icons.calculate_outlined,
                selected: _screen == AppScreen.calculator,
                onTap: () => _goTo(AppScreen.calculator),
              ),
              _DrawerItem(
                label: 'Gear Change Assistant',
                icon: Icons.tune_outlined,
                selected: _screen == AppScreen.assistant,
                onTap: () => _goTo(AppScreen.assistant),
              ),
              _DrawerItem(
                label: 'Chassis Tuning Guide',
                icon: Icons.article_outlined,
                selected: _screen == AppScreen.guide,
                onTap: () => _goTo(AppScreen.guide),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Higher FDR = more torque, less RPM\nLower FDR = more RPM, less torque',
                  style: TextStyle(color: AppTheme.mutedText),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.background, Color(0xFF14001D), AppTheme.background],
          ),
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.neonYellow : AppTheme.mutedText),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
          color: selected ? AppTheme.neonYellow : AppTheme.white,
        ),
      ),
      selected: selected,
      selectedTileColor: AppTheme.hotPink.withOpacity(0.14),
      onTap: onTap,
    );
  }
}

class SharedSetupData {
  const SharedSetupData({
    required this.pinionController,
    required this.spurController,
    required this.transmissionController,
    required this.tireDiameterController,
    required this.tireCircumferenceController,
    required this.tireUnit,
    required this.onTireUnitChanged,
    required this.baselineSetup,
    required this.tireCircumference,
  });

  final TextEditingController pinionController;
  final TextEditingController spurController;
  final TextEditingController transmissionController;
  final TextEditingController tireDiameterController;
  final TextEditingController tireCircumferenceController;
  final TireUnit tireUnit;
  final ValueChanged<TireUnit> onTireUnitChanged;
  final GearSetup? baselineSetup;
  final double? tireCircumference;
}

class GearTextInput extends StatelessWidget {
  const GearTextInput({
    super.key,
    required this.label,
    required this.controller,
    this.decimal = false,
  });

  final String label;
  final TextEditingController controller;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
      ],
      decoration: InputDecoration(labelText: label),
    );
  }
}
