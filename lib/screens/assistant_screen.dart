import 'package:flutter/material.dart';

import '../models/app_preferences.dart';

import '../models/gear_setup.dart';
import '../services/gear_ratio_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import '../widgets/setup_input_card.dart';
import 'app_shell.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, required this.shared});

  final SharedSetupData shared;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  GearSymptom? _selectedSymptom = RecommendationService.symptoms.first;

  @override
  Widget build(BuildContext context) {
    final baseline = widget.shared.baselineSetup;
    final recommendation = baseline != null && _selectedSymptom != null
        ? RecommendationService.buildRecommendation(baseline: baseline, symptom: _selectedSymptom!)
        : null;

    return SingleChildScrollView(
      padding: AppPreferencesScope.of(context).layoutDensity.screenPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Gear Change Assistant', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    SizedBox(height: 8),
                    Text(
                      'Pick a gearing symptom and the app will suggest a pinion or spur direction using the current setup.',
                      style: TextStyle(color: AppTheme.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SetupInputCard(shared: widget.shared),
              const SizedBox(height: 14),
              _SymptomCard(
                selected: _selectedSymptom,
                onChanged: (symptom) => setState(() => _selectedSymptom = symptom),
              ),
              const SizedBox(height: 14),
              if (baseline == null)
                const NeonCard(
                  child: Text('Enter valid pinion, spur, and transmission ratio values.', style: TextStyle(color: AppTheme.neonYellow)),
                )
              else if (recommendation != null)
                _RecommendationCard(
                  baseline: baseline,
                  recommendation: recommendation,
                  tireCircumference: widget.shared.tireCircumference,
                  tireUnit: widget.shared.tireUnit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  const _SymptomCard({
    required this.selected,
    required this.onChanged,
  });

  final GearSymptom? selected;
  final ValueChanged<GearSymptom?> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Gearing symptom', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          DropdownButtonFormField<GearSymptom>(
            value: selected,
            decoration: const InputDecoration(labelText: 'What are you trying to fix?'),
            items: RecommendationService.symptoms
                .map(
                  (symptom) => DropdownMenuItem<GearSymptom>(
                    value: symptom,
                    child: Text(symptom.label),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.baseline,
    required this.recommendation,
    required this.tireCircumference,
    required this.tireUnit,
  });

  final GearSetup baseline;
  final GearRecommendation recommendation;
  final double? tireCircumference;
  final TireUnit tireUnit;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Suggested direction', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            recommendation.directionLabel,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.neonYellow),
          ),
          const SizedBox(height: 8),
          Text(recommendation.reason),
          const SizedBox(height: 16),
          _SetupSummaryTile(
            title: 'Current setup',
            setup: baseline,
            tireCircumference: tireCircumference,
            tireUnit: tireUnit,
            highlight: AppTheme.purple,
          ),
          const SizedBox(height: 10),
          _SetupSummaryTile(
            title: recommendation.direction == GearChangeDirection.increaseFdr
                ? 'Option A: smaller pinion'
                : 'Option A: larger pinion',
            setup: recommendation.pinionOption,
            baseline: baseline,
            tireCircumference: tireCircumference,
            tireUnit: tireUnit,
            highlight: AppTheme.hotPink,
          ),
          const SizedBox(height: 10),
          _SetupSummaryTile(
            title: recommendation.direction == GearChangeDirection.increaseFdr
                ? 'Option B: larger spur'
                : 'Option B: smaller spur',
            setup: recommendation.spurOption,
            baseline: baseline,
            tireCircumference: tireCircumference,
            tireUnit: tireUnit,
            highlight: AppTheme.electricBlue,
          ),
        ],
      ),
    );
  }
}

class _SetupSummaryTile extends StatelessWidget {
  const _SetupSummaryTile({
    required this.title,
    required this.setup,
    required this.tireCircumference,
    required this.tireUnit,
    required this.highlight,
    this.baseline,
  });

  final String title;
  final GearSetup setup;
  final GearSetup? baseline;
  final double? tireCircumference;
  final TireUnit tireUnit;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    final rollout = GearRatioService.calculateRollout(tireCircumference: tireCircumference, setup: setup);
    return Container(
      padding: AppPreferencesScope.of(context).layoutDensity.screenPadding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: highlight, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(setup.gearLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text('FDR: ${GearRatioService.formatRatio(setup.overallDriveRatio)}'),
          if (rollout != null)
            Text('Rollout: ${GearRatioService.formatMeasurement(rollout, tireUnit)} ${tireUnit.abbreviation}/rev'),
          if (baseline != null)
            Text(
              RecommendationService.optionSummary(baseline!, setup),
              style: const TextStyle(color: AppTheme.mutedText),
            ),
        ],
      ),
    );
  }
}
