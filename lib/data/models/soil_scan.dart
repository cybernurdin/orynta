/// Mirrors the `SoilScan` + `CropRecommendation` entities in
/// Orynta_SRS.md §7. `source` is kept even though only `photo` is
/// wired up at MVP — FR-1.5 (BLE sensor) writes to this same shape
/// later without a schema change.
enum SoilScanSource { photo, sensor }

enum SoilType { clay, sandy, loam, silt, mixed }

enum FertilityBand { low, medium, high }

class CropRecommendation {
  final String cropName;
  final int rank;
  final String rationale;

  const CropRecommendation({
    required this.cropName,
    required this.rank,
    required this.rationale,
  });

  Map<String, dynamic> toJson() => {
        'cropName': cropName,
        'rank': rank,
        'rationale': rationale,
      };

  factory CropRecommendation.fromJson(Map<String, dynamic> json) =>
      CropRecommendation(
        cropName: json['cropName'] as String,
        rank: json['rank'] as int,
        rationale: json['rationale'] as String,
      );
}

class SoilScan {
  final String id;
  final SoilScanSource source;
  final DateTime capturedAt;
  final SoilType soilType;
  final FertilityBand fertilityBand;
  final double confidence;
  final String modelVersion;
  final String? imagePath;
  final List<CropRecommendation> recommendations;
  final bool synced;
  final double phLevel;
  final double moisturePercent;
  final double healthScore;
  final double nitrogenPercent;
  final double phosphorusPercent;
  final double potassiumPercent;
  final String region;
  final List<String> smartRecommendations;

  const SoilScan({
    required this.id,
    required this.source,
    required this.capturedAt,
    required this.soilType,
    required this.fertilityBand,
    required this.confidence,
    required this.modelVersion,
    required this.recommendations,
    this.imagePath,
    this.synced = false,
    this.phLevel = 6.5,
    this.moisturePercent = 50,
    this.healthScore = 65,
    this.nitrogenPercent = 50,
    this.phosphorusPercent = 50,
    this.potassiumPercent = 50,
    this.region = 'Not set',
    this.smartRecommendations = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source.name,
        'capturedAt': capturedAt.toIso8601String(),
        'soilType': soilType.name,
        'fertilityBand': fertilityBand.name,
        'confidence': confidence,
        'modelVersion': modelVersion,
        'imagePath': imagePath,
        'recommendations': recommendations.map((e) => e.toJson()).toList(),
        'synced': synced,
        'phLevel': phLevel,
        'moisturePercent': moisturePercent,
        'healthScore': healthScore,
        'nitrogenPercent': nitrogenPercent,
        'phosphorusPercent': phosphorusPercent,
        'potassiumPercent': potassiumPercent,
        'region': region,
        'smartRecommendations': smartRecommendations,
      };

  factory SoilScan.fromJson(Map<String, dynamic> json) => SoilScan(
        id: json['id'] as String,
        source: SoilScanSource.values.byName(json['source'] as String),
        capturedAt: DateTime.parse(json['capturedAt'] as String),
        soilType: SoilType.values.byName(json['soilType'] as String),
        fertilityBand:
            FertilityBand.values.byName(json['fertilityBand'] as String),
        confidence: (json['confidence'] as num).toDouble(),
        modelVersion: json['modelVersion'] as String,
        imagePath: json['imagePath'] as String?,
        recommendations: (json['recommendations'] as List)
            .map((e) => CropRecommendation.fromJson(e as Map<String, dynamic>))
            .toList(),
        synced: json['synced'] as bool? ?? false,
        phLevel: (json['phLevel'] as num?)?.toDouble() ?? 6.5,
        moisturePercent: (json['moisturePercent'] as num?)?.toDouble() ?? 50,
        healthScore: (json['healthScore'] as num?)?.toDouble() ?? 65,
        nitrogenPercent: (json['nitrogenPercent'] as num?)?.toDouble() ?? 50,
        phosphorusPercent: (json['phosphorusPercent'] as num?)?.toDouble() ?? 50,
        potassiumPercent: (json['potassiumPercent'] as num?)?.toDouble() ?? 50,
        region: json['region'] as String? ?? 'Not set',
        smartRecommendations:
            (json['smartRecommendations'] as List?)?.map((e) => e as String).toList() ?? const [],
      );
}
