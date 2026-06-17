import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_preferences.dart';
import '../models/car_profile.dart';
import '../models/gear_setup.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import 'app_shell.dart';

class CarProfilesScreen extends StatefulWidget {
  const CarProfilesScreen({
    super.key,
    required this.shared,
    required this.carProfiles,
    required this.onSaveProfile,
    required this.onDeleteProfile,
    required this.onUseProfile,
  });

  final SharedSetupData shared;
  final List<CarProfile> carProfiles;
  final ValueChanged<CarProfile> onSaveProfile;
  final ValueChanged<CarProfile> onDeleteProfile;
  final ValueChanged<CarProfile> onUseProfile;

  @override
  State<CarProfilesScreen> createState() => _CarProfilesScreenState();
}

class _CarProfilesScreenState extends State<CarProfilesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _pinionController = TextEditingController();
  final TextEditingController _spurController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _tireDiameterController = TextEditingController();
  final TextEditingController _tireCircumferenceController = TextEditingController();
  final TextEditingController _tireManufacturerController = TextEditingController();
  final TextEditingController _treadPatternController = TextEditingController();
  final TextEditingController _compoundController = TextEditingController();
  final TextEditingController _wheelManufacturerController = TextEditingController();
  final TextEditingController _wheelModelController = TextEditingController();
  final TextEditingController _wheelOffsetController = TextEditingController();
  final TextEditingController _transpondersController = TextEditingController();
  final TextEditingController _motorController = TextEditingController();
  final TextEditingController _escController = TextEditingController();
  final TextEditingController _batteryController = TextEditingController();
  final TextEditingController _motorTempController = TextEditingController();
  final TextEditingController _trackNameController = TextEditingController();
  final TextEditingController _surfaceTypeOtherController = TextEditingController();
  final TextEditingController _raceLengthController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _editingId;
  String? _expandedProfileId;
  SetupRating _setupRating = SetupRating.none;
  TireUnit _tireUnit = TireUnit.inches;
  TrackLocation _trackLocation = TrackLocation.outdoor;
  String _surfaceType = SurfaceTypeOption.asphalt;
  RaceLengthType _raceLengthType = RaceLengthType.laps;

  @override
  void initState() {
    super.initState();
    _seedFromCalculator();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _pinionController.dispose();
    _spurController.dispose();
    _transmissionController.dispose();
    _tireDiameterController.dispose();
    _tireCircumferenceController.dispose();
    _tireManufacturerController.dispose();
    _treadPatternController.dispose();
    _compoundController.dispose();
    _wheelManufacturerController.dispose();
    _wheelModelController.dispose();
    _wheelOffsetController.dispose();
    _transpondersController.dispose();
    _motorController.dispose();
    _escController.dispose();
    _batteryController.dispose();
    _motorTempController.dispose();
    _trackNameController.dispose();
    _surfaceTypeOtherController.dispose();
    _raceLengthController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _seedFromCalculator() {
    _editingId = null;
    _expandedProfileId = null;
    _setupRating = SetupRating.none;
    _nameController.clear();
    _classController.clear();
    _transpondersController.clear();
    _pinionController.text = widget.shared.pinionController.text;
    _spurController.text = widget.shared.spurController.text;
    _transmissionController.text = widget.shared.transmissionController.text;
    _tireUnit = widget.shared.tireUnit;
    _tireDiameterController.text = widget.shared.tireDiameterController.text;
    _tireCircumferenceController.text = widget.shared.tireCircumferenceController.text;
    _tireManufacturerController.clear();
    _treadPatternController.clear();
    _compoundController.clear();
    _wheelManufacturerController.clear();
    _wheelModelController.clear();
    _wheelOffsetController.clear();
    _motorController.clear();
    _escController.clear();
    _batteryController.clear();
    _motorTempController.clear();
    _trackNameController.clear();
    _trackLocation = TrackLocation.outdoor;
    _surfaceType = SurfaceTypeOption.asphalt;
    _surfaceTypeOtherController.clear();
    _raceLengthType = RaceLengthType.laps;
    _raceLengthController.clear();
    _conditionsController.clear();
    _notesController.clear();
  }

  void _loadForEditing(CarProfile profile) {
    setState(() {
      _editingId = profile.id;
      _expandedProfileId = _expandedProfileId == profile.id ? null : profile.id;
      _setupRating = profile.setupRating;
      _nameController.text = profile.name;
      _classController.text = profile.carClass;
      _transpondersController.text = profile.transponderNumbers.join('\n');
      _pinionController.text = profile.pinion?.toString() ?? '';
      _spurController.text = profile.spur?.toString() ?? '';
      _transmissionController.text = profile.transmissionRatio?.toStringAsFixed(2) ?? '';
      _tireUnit = profile.tireUnit;
      _tireDiameterController.text = profile.tireDiameter == null ? '' : profile.tireDiameter!.toStringAsFixed(profile.tireUnit == TireUnit.inches ? 3 : 1);
      _tireCircumferenceController.text = profile.tireCircumference == null ? '' : profile.tireCircumference!.toStringAsFixed(profile.tireUnit == TireUnit.inches ? 3 : 1);
      _tireManufacturerController.text = profile.tireManufacturer;
      _treadPatternController.text = profile.treadPattern;
      _compoundController.text = profile.compound;
      _wheelManufacturerController.text = profile.wheelManufacturer;
      _wheelModelController.text = profile.wheelModel;
      _wheelOffsetController.text = profile.wheelOffset;
      _motorController.text = profile.motor;
      _escController.text = profile.esc;
      _batteryController.text = profile.battery;
      _motorTempController.text = profile.motorTemp;
      _trackNameController.text = profile.trackName;
      _trackLocation = profile.trackLocation;
      _surfaceType = SurfaceTypeOption.values.contains(profile.surfaceType) ? profile.surfaceType : SurfaceTypeOption.other;
      _surfaceTypeOtherController.text = profile.surfaceTypeOther;
      if (profile.surfaceType == 'Outdoor asphalt') _surfaceType = SurfaceTypeOption.asphalt;
      if (profile.surfaceType == 'Indoor carpet' || profile.surfaceType == 'Outdoor carpet') _surfaceType = SurfaceTypeOption.carpet;
      _raceLengthType = profile.raceLengthType;
      _raceLengthController.text = profile.raceLength;
      _conditionsController.text = profile.conditions;
      _notesController.text = profile.notes;
    });
  }

  void _copyCurrentCalculatorValuesIntoForm() {
    setState(() {
      _pinionController.text = widget.shared.pinionController.text;
      _spurController.text = widget.shared.spurController.text;
      _transmissionController.text = widget.shared.transmissionController.text;
      _tireUnit = widget.shared.tireUnit;
      _tireDiameterController.text = widget.shared.tireDiameterController.text;
      _tireCircumferenceController.text = widget.shared.tireCircumferenceController.text;
    });
  }

  void _save() {
    final now = DateTime.now();
    final profile = CarProfile(
      id: _editingId ?? now.microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      carClass: _classController.text.trim(),
      setupRating: _setupRating,
      pinion: int.tryParse(_pinionController.text.trim()),
      spur: int.tryParse(_spurController.text.trim()),
      transmissionRatio: double.tryParse(_transmissionController.text.trim()),
      tireUnit: _tireUnit,
      tireDiameter: double.tryParse(_tireDiameterController.text.trim()),
      tireCircumference: double.tryParse(_tireCircumferenceController.text.trim()),
      tireManufacturer: _tireManufacturerController.text.trim(),
      treadPattern: _treadPatternController.text.trim(),
      compound: _compoundController.text.trim(),
      wheelManufacturer: _wheelManufacturerController.text.trim(),
      wheelModel: _wheelModelController.text.trim(),
      wheelOffset: _wheelOffsetController.text.trim(),
      motor: _motorController.text.trim(),
      esc: _escController.text.trim(),
      battery: _batteryController.text.trim(),
      motorTemp: _motorTempController.text.trim(),
      trackName: _trackNameController.text.trim(),
      trackLocation: _trackLocation,
      surfaceType: _surfaceType,
      surfaceTypeOther: _surfaceTypeOtherController.text.trim(),
      raceLengthType: _raceLengthType,
      raceLength: _raceLengthController.text.trim(),
      conditions: _conditionsController.text.trim(),
      transponderNumbers: _transpondersController.text
          .split(RegExp(r'[\n,; ]+'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(),
      notes: _notesController.text.trim(),
      updatedAt: now,
    );

    widget.onSaveProfile(profile);
    setState(() {
      _editingId = profile.id;
      _expandedProfileId = profile.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved ${profile.displayName}.')));
  }

  Future<void> _confirmDelete(CarProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${profile.displayName}?'),
        content: const Text('This removes the saved car from this browser.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDeleteProfile(profile);
      if (_editingId == profile.id) setState(_seedFromCalculator);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferencesScope.of(context);
    final twoColumns = MediaQuery.of(context).size.width >= 820;

    final form = _CarProfileForm(
      editing: _editingId != null,
      setupRating: _setupRating,
      onSetupRatingChanged: (value) => setState(() => _setupRating = value),
      nameController: _nameController,
      classController: _classController,
      transpondersController: _transpondersController,
      pinionController: _pinionController,
      spurController: _spurController,
      transmissionController: _transmissionController,
      tireDiameterController: _tireDiameterController,
      tireCircumferenceController: _tireCircumferenceController,
      tireManufacturerController: _tireManufacturerController,
      treadPatternController: _treadPatternController,
      compoundController: _compoundController,
      wheelManufacturerController: _wheelManufacturerController,
      wheelModelController: _wheelModelController,
      wheelOffsetController: _wheelOffsetController,
      tireUnit: _tireUnit,
      onTireUnitChanged: (unit) => setState(() => _tireUnit = unit),
      motorController: _motorController,
      escController: _escController,
      batteryController: _batteryController,
      motorTempController: _motorTempController,
      trackNameController: _trackNameController,
      trackLocation: _trackLocation,
      onTrackLocationChanged: (location) => setState(() => _trackLocation = location),
      surfaceType: _surfaceType,
      onSurfaceTypeChanged: (surfaceType) => setState(() => _surfaceType = surfaceType),
      surfaceTypeOtherController: _surfaceTypeOtherController,
      raceLengthType: _raceLengthType,
      onRaceLengthTypeChanged: (type) {
        setState(() {
          _raceLengthType = type;
          _raceLengthController.clear();
        });
      },
      raceLengthController: _raceLengthController,
      conditionsController: _conditionsController,
      notesController: _notesController,
      onNewFromCalculator: () => setState(_seedFromCalculator),
      onCopyCalculatorValues: _copyCurrentCalculatorValuesIntoForm,
      onSave: _save,
    );

    final list = _SavedCarsList(
      profiles: widget.carProfiles,
      expandedProfileId: _expandedProfileId,
      editingProfileId: _editingId,
      onSelect: _loadForEditing,
      onUse: widget.onUseProfile,
      onDelete: _confirmDelete,
    );

    return SingleChildScrollView(
      padding: prefs.layoutDensity.screenPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Cars, transponders & notes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    SizedBox(height: 8),
                    Text(
                      'Tap a saved car to edit it. Sections keep the setup details from crowding the phone screen.',
                      style: TextStyle(color: AppTheme.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (twoColumns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: form),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: list),
                  ],
                )
              else ...[
                form,
                const SizedBox(height: 12),
                list,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CarProfileForm extends StatelessWidget {
  const _CarProfileForm({
    required this.editing,
    required this.setupRating,
    required this.onSetupRatingChanged,
    required this.nameController,
    required this.classController,
    required this.transpondersController,
    required this.pinionController,
    required this.spurController,
    required this.transmissionController,
    required this.tireDiameterController,
    required this.tireCircumferenceController,
    required this.tireManufacturerController,
    required this.treadPatternController,
    required this.compoundController,
    required this.wheelManufacturerController,
    required this.wheelModelController,
    required this.wheelOffsetController,
    required this.tireUnit,
    required this.onTireUnitChanged,
    required this.motorController,
    required this.escController,
    required this.batteryController,
    required this.motorTempController,
    required this.trackNameController,
    required this.trackLocation,
    required this.onTrackLocationChanged,
    required this.surfaceType,
    required this.onSurfaceTypeChanged,
    required this.surfaceTypeOtherController,
    required this.raceLengthType,
    required this.onRaceLengthTypeChanged,
    required this.raceLengthController,
    required this.conditionsController,
    required this.notesController,
    required this.onNewFromCalculator,
    required this.onCopyCalculatorValues,
    required this.onSave,
  });

  final bool editing;
  final SetupRating setupRating;
  final ValueChanged<SetupRating> onSetupRatingChanged;
  final TextEditingController nameController;
  final TextEditingController classController;
  final TextEditingController transpondersController;
  final TextEditingController pinionController;
  final TextEditingController spurController;
  final TextEditingController transmissionController;
  final TextEditingController tireDiameterController;
  final TextEditingController tireCircumferenceController;
  final TextEditingController tireManufacturerController;
  final TextEditingController treadPatternController;
  final TextEditingController compoundController;
  final TextEditingController wheelManufacturerController;
  final TextEditingController wheelModelController;
  final TextEditingController wheelOffsetController;
  final TireUnit tireUnit;
  final ValueChanged<TireUnit> onTireUnitChanged;
  final TextEditingController motorController;
  final TextEditingController escController;
  final TextEditingController batteryController;
  final TextEditingController motorTempController;
  final TextEditingController trackNameController;
  final TrackLocation trackLocation;
  final ValueChanged<TrackLocation> onTrackLocationChanged;
  final String surfaceType;
  final ValueChanged<String> onSurfaceTypeChanged;
  final TextEditingController surfaceTypeOtherController;
  final RaceLengthType raceLengthType;
  final ValueChanged<RaceLengthType> onRaceLengthTypeChanged;
  final TextEditingController raceLengthController;
  final TextEditingController conditionsController;
  final TextEditingController notesController;
  final VoidCallback onNewFromCalculator;
  final VoidCallback onCopyCalculatorValues;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            editing ? 'Edit saved car' : 'New car profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            editing ? 'Changes are only saved when you press Update car.' : 'Car is expanded by default. Open only the sections you need.',
            style: const TextStyle(color: AppTheme.mutedText),
          ),
          const SizedBox(height: 8),
          _SetupSection(
            title: 'Car',
            initiallyExpanded: true,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Car name')),
              const SizedBox(height: 10),
              TextField(controller: classController, decoration: const InputDecoration(labelText: 'Class')),
              const SizedBox(height: 10),
              DropdownButtonFormField<SetupRating>(
                value: setupRating,
                decoration: const InputDecoration(labelText: 'Setup rating'),
                items: SetupRating.values.map((rating) => DropdownMenuItem(value: rating, child: Text(rating.label))).toList(),
                onChanged: (value) {
                  if (value != null) onSetupRatingChanged(value);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: transpondersController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Transponder(s)',
                  helperText: 'Separate with a space, comma, or new line.',
                ),
              ),
            ],
          ),
          _SetupSection(
            title: 'Overall Drive Ratio',
            children: [
              _ResponsiveFields(
                fields: [
                  GearTextInput(label: 'Pinion', controller: pinionController),
                  GearTextInput(label: 'Spur', controller: spurController),
                  GearTextInput(label: 'Transmission', controller: transmissionController, decimal: true),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onCopyCalculatorValues,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy calculator gearing'),
              ),
            ],
          ),
          _SetupSection(
            title: 'Tire / Wheel',
            children: [
              SegmentedButton<TireUnit>(
                segments: TireUnit.values.map((unit) => ButtonSegment<TireUnit>(value: unit, label: Text(unit.label))).toList(),
                selected: {tireUnit},
                onSelectionChanged: (selection) => onTireUnitChanged(selection.first),
              ),
              const SizedBox(height: 10),
              _ResponsiveFields(
                fields: [
                  GearTextInput(label: 'Diameter (${tireUnit.abbreviation})', controller: tireDiameterController, decimal: true),
                  GearTextInput(label: 'Circumference (${tireUnit.abbreviation})', controller: tireCircumferenceController, decimal: true),
                ],
              ),
              const SizedBox(height: 10),
              _ResponsiveFields(
                fields: [
                  TextField(controller: tireManufacturerController, decoration: const InputDecoration(labelText: 'Tire manufacturer')),
                  TextField(controller: treadPatternController, decoration: const InputDecoration(labelText: 'Tread pattern')),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: compoundController, decoration: const InputDecoration(labelText: 'Compound')),
              const SizedBox(height: 10),
              _ResponsiveFields(
                fields: [
                  TextField(controller: wheelManufacturerController, decoration: const InputDecoration(labelText: 'Wheel manufacturer')),
                  TextField(controller: wheelModelController, decoration: const InputDecoration(labelText: 'Wheel model')),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: wheelOffsetController, decoration: const InputDecoration(labelText: 'Wheel offset')),
            ],
          ),
          _SetupSection(
            title: 'Electronics',
            children: [
              TextField(controller: motorController, decoration: const InputDecoration(labelText: 'Motor')),
              const SizedBox(height: 10),
              TextField(controller: escController, decoration: const InputDecoration(labelText: 'ESC')),
              const SizedBox(height: 10),
              TextField(controller: batteryController, decoration: const InputDecoration(labelText: 'Battery')),
              const SizedBox(height: 10),
              TextField(
                controller: motorTempController,
                decoration: const InputDecoration(
                  labelText: 'Motor temp',
                  helperText: 'Examples: 145°F after 5 minutes, 145°F',
                ),
              ),
            ],
          ),
          _SetupSection(
            title: 'Track',
            children: [
              TextField(controller: trackNameController, decoration: const InputDecoration(labelText: 'Track name')),
              const SizedBox(height: 10),
              SegmentedButton<TrackLocation>(
                segments: TrackLocation.values.map((location) => ButtonSegment<TrackLocation>(value: location, label: Text(location.label))).toList(),
                selected: {trackLocation},
                onSelectionChanged: (selection) => onTrackLocationChanged(selection.first),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: surfaceType,
                decoration: const InputDecoration(labelText: 'Surface type'),
                items: SurfaceTypeOption.values.map((surface) => DropdownMenuItem(value: surface, child: Text(surface))).toList(),
                onChanged: (value) {
                  if (value != null) onSurfaceTypeChanged(value);
                },
              ),
              if (surfaceType == SurfaceTypeOption.other) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: surfaceTypeOtherController,
                  decoration: const InputDecoration(labelText: 'Other surface type'),
                ),
              ],
              const SizedBox(height: 10),
              SegmentedButton<RaceLengthType>(
                segments: RaceLengthType.values.map((type) => ButtonSegment<RaceLengthType>(value: type, label: Text(type.label))).toList(),
                selected: {raceLengthType},
                onSelectionChanged: (selection) => onRaceLengthTypeChanged(selection.first),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: raceLengthController,
                keyboardType: raceLengthType == RaceLengthType.laps ? TextInputType.number : TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(raceLengthType == RaceLengthType.laps ? RegExp(r'[0-9]') : RegExp(r'[0-9:]')),
                ],
                decoration: InputDecoration(
                  labelText: raceLengthType == RaceLengthType.laps ? 'Race length' : 'Race length (MM:SS)',
                  helperText: raceLengthType == RaceLengthType.laps ? 'Example: 50 laps' : 'Example: 5:00 minutes',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: conditionsController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Conditions'),
              ),
            ],
          ),
          _SetupSection(
            title: 'Notes',
            children: [
              TextField(
                controller: notesController,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(labelText: 'General notes'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(onPressed: onSave, icon: const Icon(Icons.save_outlined), label: Text(editing ? 'Update car' : 'Save car')),
              OutlinedButton.icon(onPressed: onNewFromCalculator, icon: const Icon(Icons.add_circle_outline), label: const Text('New from calculator')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupSection extends StatelessWidget {
  const _SetupSection({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 12, bottom: 12),
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.neonYellow)),
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.fields});

  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 420;
        if (!twoColumns) {
          return Column(
            children: [
              for (final field in fields) Padding(padding: const EdgeInsets.only(bottom: 10), child: field),
            ],
          );
        }

        return Row(
          children: [
            for (final field in fields) Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: field)),
          ],
        );
      },
    );
  }
}

class _SavedCarsList extends StatelessWidget {
  const _SavedCarsList({
    required this.profiles,
    required this.expandedProfileId,
    required this.editingProfileId,
    required this.onSelect,
    required this.onUse,
    required this.onDelete,
  });

  final List<CarProfile> profiles;
  final String? expandedProfileId;
  final String? editingProfileId;
  final ValueChanged<CarProfile> onSelect;
  final ValueChanged<CarProfile> onUse;
  final ValueChanged<CarProfile> onDelete;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppPreferencesScope.of(context).layoutDensity.cardPadding,
            child: Text('Saved cars', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          ),
          if (profiles.isEmpty)
            Padding(
              padding: AppPreferencesScope.of(context).layoutDensity.cardPadding,
              child: const Text('No cars saved yet. Add one to test the profile and notes flow.', style: TextStyle(color: AppTheme.mutedText)),
            )
          else
            for (var i = 0; i < profiles.length; i++) ...[
              _SavedCarBaseRow(
                profile: profiles[i],
                selected: profiles[i].id == editingProfileId,
                expanded: profiles[i].id == expandedProfileId,
                onTap: () => onSelect(profiles[i]),
              ),
              if (profiles[i].id == expandedProfileId)
                _SavedCarControlsRow(
                  profile: profiles[i],
                  onUse: profiles[i].setup == null ? null : () => onUse(profiles[i]),
                  onDelete: () => onDelete(profiles[i]),
                ),
              if (i != profiles.length - 1) Divider(height: 1, color: AppTheme.white.withOpacity(0.10)),
            ],
        ],
      ),
    );
  }
}

class _SavedCarBaseRow extends StatelessWidget {
  const _SavedCarBaseRow({
    required this.profile,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final CarProfile profile;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.hotPink.withOpacity(0.16) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppPreferencesScope.of(context).layoutDensity.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(expanded ? Icons.keyboard_arrow_down : Icons.chevron_right, color: selected ? AppTheme.neonYellow : AppTheme.mutedText),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(profile.classTrackLabel, style: const TextStyle(color: AppTheme.mutedText)),
                  ],
                ),
              ),
              if (profile.setupRating != SetupRating.none)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _ratingColor(profile.setupRating).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _ratingColor(profile.setupRating).withOpacity(0.65)),
                  ),
                  child: Text(profile.setupRating.label, style: TextStyle(color: _ratingColor(profile.setupRating), fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _ratingColor(SetupRating rating) => switch (rating) {
        SetupRating.good => AppTheme.neonYellow,
        SetupRating.watch => AppTheme.electricBlue,
        SetupRating.bad => AppTheme.hotPink,
        SetupRating.none => AppTheme.mutedText,
      };
}

class _SavedCarControlsRow extends StatelessWidget {
  const _SavedCarControlsRow({
    required this.profile,
    required this.onDelete,
    this.onUse,
  });

  final CarProfile profile;
  final VoidCallback? onUse;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.24),
      padding: AppPreferencesScope.of(context).layoutDensity.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.notes.isNotEmpty) ...[
            const Text('Quick notes', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.neonYellow)),
            const SizedBox(height: 4),
            Text(profile.notes, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 8),
          ] else ...[
            const Text('No quick notes saved.', style: TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(onPressed: onUse, icon: const Icon(Icons.input_outlined), label: const Text('Use in calc')),
              TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline), label: const Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
