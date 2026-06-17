import 'package:flutter/material.dart';

import '../models/app_preferences.dart';

import '../models/gear_setup.dart';
import '../services/gear_ratio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import '../widgets/setup_input_card.dart';
import 'app_shell.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.shared});

  final SharedSetupData shared;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  GearSetup? _selectedSetup;

  @override
  Widget build(BuildContext context) {
    final baseline = widget.shared.baselineSetup;
    if (_selectedSetup != null && baseline != null) {
      final inRange = GearRatioService.pinionRange(baseline.pinion).contains(_selectedSetup!.pinion) &&
          GearRatioService.spurRange(baseline.spur).contains(_selectedSetup!.spur) &&
          _selectedSetup!.transmissionRatio == baseline.transmissionRatio;
      if (!inRange) _selectedSetup = null;
    }
    final selected = _selectedSetup ?? baseline;

    return SingleChildScrollView(
      padding: AppPreferencesScope.of(context).layoutDensity.screenPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HeroHeader(),
              const SizedBox(height: 14),
              SetupInputCard(shared: widget.shared),
              const SizedBox(height: 14),
              _ResultCard(
                baseline: baseline,
                selected: selected,
                tireCircumference: widget.shared.tireCircumference,
                tireUnit: widget.shared.tireUnit,
              ),
              const SizedBox(height: 14),
              _ResponsiveRatioChart(
                baseline: baseline,
                selected: selected,
                onSelected: (setup) => setState(() => _selectedSetup = setup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'RC Overall Drive Ratio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.white,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.neonYellow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Alpha layout build',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Calculate FDR, compare nearby gear changes, and see rollout from your tire size.',
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.baseline,
    required this.selected,
    required this.tireCircumference,
    required this.tireUnit,
  });

  final GearSetup? baseline;
  final GearSetup? selected;
  final double? tireCircumference;
  final TireUnit tireUnit;

  @override
  Widget build(BuildContext context) {
    final rollout = GearRatioService.calculateRollout(tireCircumference: tireCircumference, setup: selected);

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Selected ratio', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (selected == null || baseline == null)
            const Text('Enter valid pinion, spur, and transmission ratio values.', style: TextStyle(color: AppTheme.neonYellow))
          else ...[
            Text(selected!.gearLabel, style: const TextStyle(color: AppTheme.mutedText, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              GearRatioService.formatRatio(selected!.overallDriveRatio),
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppTheme.neonYellow, height: 1),
            ),
            const Text('Final drive ratio / overall drive ratio', style: TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 12),
            if (rollout == null)
              const Text('Enter tire diameter or circumference to calculate rollout.', style: TextStyle(color: AppTheme.mutedText))
            else
              Text(
                'Rollout: ${GearRatioService.formatMeasurement(rollout, tireUnit)} ${tireUnit.abbreviation}/rev',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.electricBlue),
              ),
            const SizedBox(height: 12),
            Text(
              GearRatioService.gearChangeSummary(baseline: baseline!, selected: selected!),
              style: const TextStyle(color: AppTheme.mutedText, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(GearRatioService.selectedRatioComment(baseline: baseline!, selected: selected!)),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveRatioChart extends StatelessWidget {
  const _ResponsiveRatioChart({
    required this.baseline,
    required this.selected,
    required this.onSelected,
  });

  final GearSetup? baseline;
  final GearSetup? selected;
  final ValueChanged<GearSetup> onSelected;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ratio comparison chart', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Spur is vertical. Pinion is horizontal. Tap a cell to compare.', style: TextStyle(color: AppTheme.mutedText)),
          const SizedBox(height: 12),
          if (baseline == null)
            const Text('Enter a valid baseline setup to build the chart.', style: TextStyle(color: AppTheme.neonYellow))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const columnCount = 6; // row label + 5 pinion choices
                const cellMargin = 1.2;
                final chartWidth = constraints.maxWidth.clamp(280.0, 720.0).toDouble();
                // Each cell has left/right margin, so subtract that space before
                // dividing the available width. This keeps the full chart inside
                // the phone screen instead of overflowing by the accumulated margins.
                final cellWidth = (chartWidth / columnCount) - (cellMargin * 2);
                final cellHeight = (cellWidth * 0.72).clamp(36.0, 54.0);
                final fontSize = (cellWidth * 0.20).clamp(9.0, 14.0);
                final smallFont = (fontSize - 1).clamp(8.0, 12.0);
                final pinions = GearRatioService.pinionRange(baseline!.pinion);
                final spurs = GearRatioService.spurRange(baseline!.spur);

                return Center(
                  child: SizedBox(
                    width: chartWidth,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _ChartCell(
                              width: cellWidth,
                              height: cellHeight,
                              text: 'Spur\nPinion',
                              fontSize: smallFont,
                              color: AppTheme.panel2,
                            ),
                            for (final pinion in pinions)
                              _ChartCell(
                                width: cellWidth,
                                height: cellHeight,
                                text: '$pinion',
                                fontSize: fontSize,
                                color: AppTheme.purple.withOpacity(0.65),
                              ),
                          ],
                        ),
                        for (final spur in spurs)
                          Row(
                            children: [
                              _ChartCell(
                                width: cellWidth,
                                height: cellHeight,
                                text: '$spur',
                                fontSize: fontSize,
                                color: AppTheme.purple.withOpacity(0.65),
                              ),
                              for (final pinion in pinions)
                                _RatioChartButton(
                                  width: cellWidth,
                                  height: cellHeight,
                                  fontSize: fontSize,
                                  baseline: baseline!,
                                  setup: GearSetup(
                                    pinion: pinion,
                                    spur: spur,
                                    transmissionRatio: baseline!.transmissionRatio,
                                  ),
                                  selected: selected,
                                  onTap: onSelected,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RatioChartButton extends StatelessWidget {
  const _RatioChartButton({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.baseline,
    required this.setup,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final double height;
  final double fontSize;
  final GearSetup baseline;
  final GearSetup setup;
  final GearSetup? selected;
  final ValueChanged<GearSetup> onTap;

  @override
  Widget build(BuildContext context) {
    final isBaseline = setup.pinion == baseline.pinion && setup.spur == baseline.spur;
    final isSelected = selected?.pinion == setup.pinion && selected?.spur == setup.spur;
    final diff = setup.overallDriveRatio - baseline.overallDriveRatio;
    final color = isSelected
        ? AppTheme.hotPink
        : isBaseline
            ? AppTheme.neonYellow.withOpacity(0.88)
            : diff > 0
                ? AppTheme.neonYellow.withOpacity(0.18)
                : AppTheme.electricBlue.withOpacity(0.18);
    final textColor = isBaseline || isSelected ? Colors.black : AppTheme.white;

    return GestureDetector(
      onTap: () => onTap(setup),
      child: _ChartCell(
        width: width,
        height: height,
        text: GearRatioService.formatRatio(setup.overallDriveRatio),
        fontSize: fontSize,
        color: color,
        textColor: textColor,
        borderColor: isSelected ? AppTheme.white : AppTheme.white.withOpacity(0.08),
      ),
    );
  }
}

class _ChartCell extends StatelessWidget {
  const _ChartCell({
    required this.width,
    required this.height,
    required this.text,
    required this.fontSize,
    required this.color,
    this.textColor = AppTheme.white,
    this.borderColor,
  });

  final double width;
  final double height;
  final String text;
  final double fontSize;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(1.2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: borderColor ?? AppTheme.white.withOpacity(0.08)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: textColor, height: 1.05),
      ),
    );
  }
}
