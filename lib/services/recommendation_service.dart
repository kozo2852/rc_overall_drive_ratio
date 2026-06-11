import '../models/gear_setup.dart';
import 'gear_ratio_service.dart';

enum GearChangeDirection { increaseFdr, decreaseFdr }

class GearSymptom {
  const GearSymptom({
    required this.label,
    required this.direction,
  });

  final String label;
  final GearChangeDirection direction;
}

class GearRecommendation {
  const GearRecommendation({
    required this.direction,
    required this.pinionOption,
    required this.spurOption,
    required this.reason,
  });

  final GearChangeDirection direction;
  final GearSetup pinionOption;
  final GearSetup spurOption;
  final String reason;

  String get directionLabel => switch (direction) {
        GearChangeDirection.increaseFdr => 'Increase final drive ratio',
        GearChangeDirection.decreaseFdr => 'Decrease final drive ratio',
      };
}

class RecommendationService {
  static const List<GearSymptom> symptoms = [
    GearSymptom(label: 'Need more drive off the corner', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Car feels lazy accelerating', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Need more punch', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Need more torque', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Motor is getting too hot', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Car feels over-geared', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Car bogs or struggles off the corner', direction: GearChangeDirection.increaseFdr),
    GearSymptom(label: 'Need more straightaway speed', direction: GearChangeDirection.decreaseFdr),
    GearSymptom(label: 'Car runs out of RPM too early', direction: GearChangeDirection.decreaseFdr),
    GearSymptom(label: 'Need more wheel speed', direction: GearChangeDirection.decreaseFdr),
    GearSymptom(label: 'Car feels under-geared', direction: GearChangeDirection.decreaseFdr),
    GearSymptom(label: 'Too much punch / hard to drive smoothly', direction: GearChangeDirection.decreaseFdr),
    GearSymptom(label: 'Car feels too aggressive on throttle', direction: GearChangeDirection.decreaseFdr),
  ];

  static GearRecommendation buildRecommendation({
    required GearSetup baseline,
    required GearSymptom symptom,
  }) {
    final increase = symptom.direction == GearChangeDirection.increaseFdr;

    final pinionOption = GearSetup(
      pinion: increase ? (baseline.pinion > 1 ? baseline.pinion - 1 : baseline.pinion) : baseline.pinion + 1,
      spur: baseline.spur,
      transmissionRatio: baseline.transmissionRatio,
    );

    final spurOption = GearSetup(
      pinion: baseline.pinion,
      spur: increase ? baseline.spur + 3 : (baseline.spur > 3 ? baseline.spur - 3 : baseline.spur),
      transmissionRatio: baseline.transmissionRatio,
    );

    final reason = increase
        ? 'A higher final drive ratio creates more torque and less RPM. Try a smaller pinion or larger spur when you need more pull, punch, or a safer motor load.'
        : 'A lower final drive ratio creates more RPM and less torque. Try a larger pinion or smaller spur when you need more wheel speed or straightaway speed.';

    return GearRecommendation(
      direction: symptom.direction,
      pinionOption: pinionOption,
      spurOption: spurOption,
      reason: reason,
    );
  }

  static String optionSummary(GearSetup baseline, GearSetup option) {
    final diff = GearRatioService.ratioDifference(baseline: baseline, selected: option);
    final direction = diff > 0 ? 'higher' : diff < 0 ? 'lower' : 'same';
    return '${GearRatioService.formatRatio(option.overallDriveRatio)} FDR • ${GearRatioService.formatRatio(diff.abs())} $direction than current';
  }
}
