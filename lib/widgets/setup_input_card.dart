import 'package:flutter/material.dart';

import '../models/gear_setup.dart';
import '../screens/app_shell.dart';
import '../theme/app_theme.dart';
import 'neon_card.dart';

class SetupInputCard extends StatelessWidget {
  const SetupInputCard({
    super.key,
    required this.shared,
    this.showTireInputs = true,
  });

  final SharedSetupData shared;
  final bool showTireInputs;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Current setup', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 520;
              final fields = [
                GearTextInput(label: 'Pinion', controller: shared.pinionController),
                GearTextInput(label: 'Spur', controller: shared.spurController),
                GearTextInput(label: 'Transmission ratio', controller: shared.transmissionController, decimal: true),
              ];
              if (!twoColumns) {
                return Column(children: fields.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList());
              }
              return Row(
                children: fields
                    .map((w) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: w)))
                    .toList(),
              );
            },
          ),
          if (showTireInputs) ...[
            const SizedBox(height: 16),
            Text('Tire setup', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SegmentedButton<TireUnit>(
              segments: TireUnit.values
                  .map((unit) => ButtonSegment<TireUnit>(value: unit, label: Text(unit.label)))
                  .toList(),
              selected: {shared.tireUnit},
              onSelectionChanged: (selection) => shared.onTireUnitChanged(selection.first),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 520;
                final fields = [
                  GearTextInput(
                    label: 'Tire diameter (${shared.tireUnit.abbreviation})',
                    controller: shared.tireDiameterController,
                    decimal: true,
                  ),
                  GearTextInput(
                    label: 'Tire circumference (${shared.tireUnit.abbreviation})',
                    controller: shared.tireCircumferenceController,
                    decimal: true,
                  ),
                ];
                if (!twoColumns) {
                  return Column(children: fields.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList());
                }
                return Row(children: fields.map((w) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: w))).toList());
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter either diameter or circumference. The other tire value updates automatically.',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
