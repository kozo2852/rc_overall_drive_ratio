import 'dart:math' as math;

import '../models/gear_setup.dart';

class GearRatioService {
  static String formatRatio(double value) => value.toStringAsFixed(2);

  static String formatMeasurement(double value, TireUnit unit) {
    return unit == TireUnit.inches ? value.toStringAsFixed(3) : value.toStringAsFixed(1);
  }

  static List<int> spurRange(int baselineSpur) {
    return List<int>.generate(7, (index) => baselineSpur - 3 + index)
        .where((value) => value > 0)
        .toList();
  }

  static List<int> pinionRange(int baselinePinion) {
    return List<int>.generate(5, (index) => baselinePinion - 2 + index)
        .where((value) => value > 0)
        .toList();
  }

  static double diameterToCircumference(double diameter) => diameter * math.pi;

  static double circumferenceToDiameter(double circumference) => circumference / math.pi;

  static double? calculateRollout({
    required double? tireCircumference,
    required GearSetup? setup,
  }) {
    if (tireCircumference == null || setup == null) return null;
    if (tireCircumference <= 0 || setup.overallDriveRatio <= 0) return null;
    return tireCircumference / setup.overallDriveRatio;
  }

  /// Positive difference means selected FDR is higher than baseline.
  static double ratioDifference({
    required GearSetup baseline,
    required GearSetup selected,
  }) {
    return selected.overallDriveRatio - baseline.overallDriveRatio;
  }

  static String gearChangeSummary({
    required GearSetup baseline,
    required GearSetup selected,
  }) {
    final pinionDelta = selected.pinion - baseline.pinion;
    final spurDelta = selected.spur - baseline.spur;
    final diff = ratioDifference(baseline: baseline, selected: selected);

    String signed(int value) => value > 0 ? '+$value' : value.toString();

    if (diff == 0 && pinionDelta == 0 && spurDelta == 0) {
      return 'Baseline setup';
    }

    final direction = diff > 0 ? 'higher FDR' : 'lower FDR';
    return 'Pinion ${signed(pinionDelta)}, spur ${signed(spurDelta)} • ${formatRatio(diff.abs())} $direction';
  }

  static String selectedRatioComment({
    required GearSetup baseline,
    required GearSetup selected,
  }) {
    final diff = ratioDifference(baseline: baseline, selected: selected);
    final absDiff = diff.abs();

    if (selected.pinion == baseline.pinion && selected.spur == baseline.spur) {
      return 'This is your current baseline setup. Use it as your home gear ratio before comparing changes.';
    }

    final direction = diff > 0
        ? 'Higher final drive ratio. This change creates more torque and less RPM. It may help the car pull harder off the corner, but it may reduce straightaway speed.'
        : 'Lower final drive ratio. This change creates more RPM and less torque. It may help increase wheel speed and straightaway speed, but it may reduce punch off the corner.';

    final size = absDiff < 0.20
        ? 'Small change from baseline. This is a good one-step tuning move.'
        : absDiff < 0.45
            ? 'Moderate change from baseline. Watch motor temperature, straightaway speed, and lap-time consistency.'
            : 'Large change from baseline. Watch motor temperature, battery fade, and whether the car remains easy to drive for the full run.';

    return '$direction\n\n$size';
  }
}
