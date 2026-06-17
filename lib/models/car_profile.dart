import 'gear_setup.dart';

enum SetupRating {
  none,
  good,
  watch,
  bad;

  String get label => switch (this) {
        SetupRating.none => 'Not rated',
        SetupRating.good => 'Good',
        SetupRating.watch => 'Watch',
        SetupRating.bad => 'Bad',
      };
}

enum TrackLocation {
  indoor,
  outdoor;

  String get label => switch (this) {
        TrackLocation.indoor => 'Indoor',
        TrackLocation.outdoor => 'Outdoor',
      };
}

enum RaceLengthType {
  laps,
  time;

  String get label => switch (this) {
        RaceLengthType.laps => 'Laps',
        RaceLengthType.time => 'Time',
      };
}

class SurfaceTypeOption {
  const SurfaceTypeOption._();

  static const String asphalt = 'Asphalt';
  static const String carpet = 'Carpet';
  static const String concrete = 'Concrete';
  static const String clay = 'Clay';
  static const String dirt = 'Dirt';
  static const String turf = 'Turf';
  static const String other = 'Other';

  static const List<String> values = [
    asphalt,
    carpet,
    concrete,
    clay,
    dirt,
    turf,
    other,
  ];
}

/// A saved car/setup record. This stays gear-focused while still storing the
/// electronics, track, and quick notes needed to remember why a setup worked.
class CarProfile {
  const CarProfile({
    required this.id,
    required this.name,
    required this.carClass,
    required this.setupRating,
    required this.pinion,
    required this.spur,
    required this.transmissionRatio,
    required this.tireUnit,
    required this.tireDiameter,
    required this.tireCircumference,
    required this.tireManufacturer,
    required this.treadPattern,
    required this.compound,
    required this.wheelManufacturer,
    required this.wheelModel,
    required this.wheelOffset,
    required this.motor,
    required this.esc,
    required this.battery,
    required this.motorTemp,
    required this.trackName,
    required this.trackLocation,
    required this.surfaceType,
    required this.surfaceTypeOther,
    required this.raceLengthType,
    required this.raceLength,
    required this.conditions,
    required this.transponderNumbers,
    required this.notes,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String carClass;
  final SetupRating setupRating;
  final int? pinion;
  final int? spur;
  final double? transmissionRatio;
  final TireUnit tireUnit;
  final double? tireDiameter;
  final double? tireCircumference;
  final String tireManufacturer;
  final String treadPattern;
  final String compound;
  final String wheelManufacturer;
  final String wheelModel;
  final String wheelOffset;
  final String motor;
  final String esc;
  final String battery;
  final String motorTemp;
  final String trackName;
  final TrackLocation trackLocation;
  final String surfaceType;
  final String surfaceTypeOther;
  final RaceLengthType raceLengthType;
  final String raceLength;
  final String conditions;
  final List<String> transponderNumbers;
  final String notes;
  final DateTime updatedAt;

  GearSetup? get setup {
    if (pinion == null || spur == null || transmissionRatio == null) return null;
    if (pinion! <= 0 || spur! <= 0 || transmissionRatio! <= 0) return null;
    return GearSetup(pinion: pinion!, spur: spur!, transmissionRatio: transmissionRatio!);
  }

  String get displayName => name.trim().isEmpty ? 'Unnamed car' : name.trim();

  String get classTrackLabel {
    final parts = <String>[];
    if (carClass.trim().isNotEmpty) parts.add(carClass.trim());
    if (trackName.trim().isNotEmpty) parts.add(trackName.trim());
    return parts.isEmpty ? 'No class or track saved' : parts.join(' • ');
  }

  String get effectiveSurfaceType {
    if (surfaceType == SurfaceTypeOption.other && surfaceTypeOther.trim().isNotEmpty) {
      return surfaceTypeOther.trim();
    }
    return surfaceType;
  }

  String get raceLengthLabel {
    if (raceLength.trim().isEmpty) return 'Race length not saved';
    return raceLengthType == RaceLengthType.laps ? '${raceLength.trim()} laps' : '${raceLength.trim()} minutes';
  }

  String get setupLabel {
    final parts = <String>[];
    if (pinion != null) parts.add('${pinion}T pinion');
    if (spur != null) parts.add('${spur}T spur');
    if (transmissionRatio != null) parts.add('${transmissionRatio!.toStringAsFixed(2)} trans');
    return parts.isEmpty ? 'No gear setup saved' : parts.join(' / ');
  }

  String get tireLabel {
    if (tireDiameter == null && tireCircumference == null) return 'No tire size saved';
    final unit = tireUnit.abbreviation;
    final parts = <String>[];
    if (tireDiameter != null) parts.add('Dia ${_formatMeasurement(tireDiameter!)} $unit');
    if (tireCircumference != null) parts.add('Circ ${_formatMeasurement(tireCircumference!)} $unit');
    return parts.join(' / ');
  }

  String _formatMeasurement(double value) {
    return tireUnit == TireUnit.inches ? value.toStringAsFixed(3) : value.toStringAsFixed(1);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'carClass': carClass,
        'setupRating': setupRating.name,
        'pinion': pinion,
        'spur': spur,
        'transmissionRatio': transmissionRatio,
        'tireUnit': tireUnit.name,
        'tireDiameter': tireDiameter,
        'tireCircumference': tireCircumference,
        'tireManufacturer': tireManufacturer,
        'treadPattern': treadPattern,
        'compound': compound,
        'wheelManufacturer': wheelManufacturer,
        'wheelModel': wheelModel,
        'wheelOffset': wheelOffset,
        'motor': motor,
        'esc': esc,
        'battery': battery,
        'motorTemp': motorTemp,
        'trackName': trackName,
        'trackLocation': trackLocation.name,
        'surfaceType': surfaceType,
        'surfaceTypeOther': surfaceTypeOther,
        'raceLengthType': raceLengthType.name,
        'raceLength': raceLength,
        'conditions': conditions,
        'transponderNumbers': transponderNumbers,
        'notes': notes,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CarProfile.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '');
    }

    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    T parseEnum<T extends Enum>(List<T> values, dynamic rawValue, T fallback) {
      return values.firstWhere(
        (value) => value.name == rawValue?.toString(),
        orElse: () => fallback,
      );
    }

    final oldSurfaceNote = json['trackSurfaceNotes']?.toString() ?? '';
    final rawSurfaceType = json['surfaceType']?.toString() ?? '';
    final migratedSurfaceType = switch (rawSurfaceType) {
      'Outdoor asphalt' => SurfaceTypeOption.asphalt,
      'Indoor carpet' => SurfaceTypeOption.carpet,
      'Outdoor carpet' => SurfaceTypeOption.carpet,
      _ => SurfaceTypeOption.values.contains(rawSurfaceType) ? rawSurfaceType : SurfaceTypeOption.asphalt,
    };

    return CarProfile(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? '',
      carClass: json['carClass']?.toString() ?? '',
      setupRating: parseEnum(SetupRating.values, json['setupRating'], SetupRating.none),
      pinion: parseInt(json['pinion']),
      spur: parseInt(json['spur']),
      transmissionRatio: parseDouble(json['transmissionRatio']),
      tireUnit: parseEnum(TireUnit.values, json['tireUnit'], TireUnit.inches),
      tireDiameter: parseDouble(json['tireDiameter']),
      tireCircumference: parseDouble(json['tireCircumference']),
      tireManufacturer: json['tireManufacturer']?.toString() ?? '',
      treadPattern: json['treadPattern']?.toString() ?? '',
      compound: json['compound']?.toString() ?? '',
      wheelManufacturer: json['wheelManufacturer']?.toString() ?? '',
      wheelModel: json['wheelModel']?.toString() ?? '',
      wheelOffset: json['wheelOffset']?.toString() ?? '',
      motor: json['motor']?.toString() ?? '',
      esc: json['esc']?.toString() ?? '',
      battery: json['battery']?.toString() ?? '',
      motorTemp: json['motorTemp']?.toString() ?? '',
      trackName: json['trackName']?.toString() ?? '',
      trackLocation: parseEnum(TrackLocation.values, json['trackLocation'], TrackLocation.outdoor),
      surfaceType: migratedSurfaceType,
      surfaceTypeOther: json['surfaceTypeOther']?.toString() ?? '',
      raceLengthType: parseEnum(RaceLengthType.values, json['raceLengthType'], RaceLengthType.laps),
      raceLength: json['raceLength']?.toString() ?? '',
      conditions: json['conditions']?.toString() ?? oldSurfaceNote,
      transponderNumbers: (json['transponderNumbers'] as List<dynamic>? ?? const [])
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      notes: json['notes']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
