class GearSetup {
  const GearSetup({
    required this.pinion,
    required this.spur,
    required this.transmissionRatio,
  });

  final int pinion;
  final int spur;
  final double transmissionRatio;

  double get overallDriveRatio => (spur / pinion) * transmissionRatio;

  String get gearLabel => '$pinion pinion / $spur spur';
}

enum TireUnit {
  inches,
  millimeters;

  String get label => switch (this) {
        TireUnit.inches => 'Inches',
        TireUnit.millimeters => 'Millimeters',
      };

  String get abbreviation => switch (this) {
        TireUnit.inches => 'in',
        TireUnit.millimeters => 'mm',
      };
}
