import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_preferences.dart';
import '../models/car_profile.dart';
import '../models/gear_setup.dart';
import '../services/gear_ratio_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'assistant_screen.dart';
import 'calculator_screen.dart';
import 'car_profiles_screen.dart';
import 'settings_screen.dart';
import 'tuning_guide_screen.dart';

enum AppScreen { calculator, assistant, cars, guide, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const String _carsStorageKey = 'rc_gear_ratio_car_profiles_v1';
  static const String _preferencesStorageKey = 'rc_gear_ratio_preferences_v1';

  AppScreen _screen = AppScreen.calculator;
  AppPreferences _preferences = AppPreferences.defaults;
  List<CarProfile> _carProfiles = const [];

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
    _loadSavedData();
    tireCircumferenceController.text = GearRatioService.diameterToCircumference(2.65).toStringAsFixed(3);
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

  void _loadSavedData() {
    final preferencesJson = LocalStorageService.readString(_preferencesStorageKey);
    if (preferencesJson != null) {
      try {
        _preferences = AppPreferences.fromJson(jsonDecode(preferencesJson) as Map<String, dynamic>);
      } catch (_) {
        _preferences = AppPreferences.defaults;
      }
    }

    final carsJson = LocalStorageService.readString(_carsStorageKey);
    if (carsJson != null) {
      try {
        final decoded = jsonDecode(carsJson) as List<dynamic>;
        _carProfiles = decoded
            .whereType<Map<String, dynamic>>()
            .map(CarProfile.fromJson)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } catch (_) {
        _carProfiles = const [];
      }
    }
  }

  void _savePreferences(AppPreferences preferences) {
    setState(() => _preferences = preferences);
    LocalStorageService.writeString(_preferencesStorageKey, jsonEncode(preferences.toJson()));
  }

  void _saveCarProfiles(List<CarProfile> profiles) {
    final sorted = [...profiles]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    setState(() => _carProfiles = sorted);
    LocalStorageService.writeString(
      _carsStorageKey,
      jsonEncode(sorted.map((profile) => profile.toJson()).toList()),
    );
  }

  void _upsertCarProfile(CarProfile profile) {
    final next = _carProfiles.where((existing) => existing.id != profile.id).toList()..add(profile);
    _saveCarProfiles(next);
  }

  void _deleteCarProfile(CarProfile profile) {
    _saveCarProfiles(_carProfiles.where((existing) => existing.id != profile.id).toList());
  }

  void _applyCarProfile(CarProfile profile) {
    final setup = profile.setup;
    if (setup == null) return;
    _updatingTireFields = true;
    pinionController.text = setup.pinion.toString();
    spurController.text = setup.spur.toString();
    transmissionController.text = setup.transmissionRatio.toStringAsFixed(2);
    tireUnit = profile.tireUnit;
    tireDiameterController.text = profile.tireDiameter == null
        ? ''
        : profile.tireDiameter!.toStringAsFixed(profile.tireUnit == TireUnit.inches ? 3 : 1);
    tireCircumferenceController.text = profile.tireCircumference == null
        ? ''
        : profile.tireCircumference!.toStringAsFixed(profile.tireUnit == TireUnit.inches ? 3 : 1);
    _updatingTireFields = false;
    setState(() => _screen = AppScreen.calculator);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loaded ${profile.displayName} into the calculator.')),
    );
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
      tireCircumferenceController.text = GearRatioService.diameterToCircumference(diameter).toStringAsFixed(tireUnit == TireUnit.inches ? 3 : 1);
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
      tireDiameterController.text = GearRatioService.circumferenceToDiameter(circumference).toStringAsFixed(tireUnit == TireUnit.inches ? 3 : 1);
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
      AppScreen.cars => 'Cars & Notes',
      AppScreen.guide => 'Tuning Guide',
      AppScreen.settings => 'Settings',
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
      AppScreen.cars => CarProfilesScreen(
          shared: common,
          carProfiles: _carProfiles,
          onSaveProfile: _upsertCarProfile,
          onDeleteProfile: _deleteCarProfile,
          onUseProfile: _applyCarProfile,
        ),
      AppScreen.guide => const TuningGuideScreen(),
      AppScreen.settings => SettingsScreen(
          preferences: _preferences,
          onPreferencesChanged: _savePreferences,
        ),
    };

    final media = MediaQuery.of(context);

    return AppPreferencesScope(
      preferences: _preferences,
      child: MediaQuery(
        data: media.copyWith(textScaler: TextScaler.linear(_preferences.textSize.scale)),
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
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
                    label: 'Cars & Notes',
                    icon: Icons.directions_car_filled_outlined,
                    selected: _screen == AppScreen.cars,
                    onTap: () => _goTo(AppScreen.cars),
                  ),
                  _DrawerItem(
                    label: 'Chassis Tuning Guide',
                    icon: Icons.article_outlined,
                    selected: _screen == AppScreen.guide,
                    onTap: () => _goTo(AppScreen.guide),
                  ),
                  _DrawerItem(
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    selected: _screen == AppScreen.settings,
                    onTap: () => _goTo(AppScreen.settings),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Text: ${_preferences.textSize.label}\nLayout: ${_preferences.layoutDensity.label}',
                      style: const TextStyle(color: AppTheme.mutedText),
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
        ),
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
