class SoilScanAnalysis {
  final String scanId;
  final String userId;
  final String imagePath;
  final DateTime scanDate;
  final double latitude;
  final double longitude;
  final String location;

  // Soil Analysis Results
  final String soilType; // e.g., 'Laterite', 'Clay loam', 'Sandy loam'
  final int healthScore; // 0-100
  final double phLevel;
  final double moistureLevel; // 0-100 percentage
  final Map<String, double> nutrientAnalysis; // N, P, K percentages
  final List<String> smartRecommendations;
  final List<CropRecommendation> cropRecommendations;
  final String analysisReport;

  SoilScanAnalysis({
    required this.scanId,
    required this.userId,
    required this.imagePath,
    required this.scanDate,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.soilType,
    required this.healthScore,
    required this.phLevel,
    required this.moistureLevel,
    required this.nutrientAnalysis,
    required this.smartRecommendations,
    required this.cropRecommendations,
    required this.analysisReport,
  });

  factory SoilScanAnalysis.fromJson(Map<String, dynamic> json) {
    return SoilScanAnalysis(
      scanId: json['scanId'] as String,
      userId: json['userId'] as String,
      imagePath: json['imagePath'] as String,
      scanDate: DateTime.parse(json['scanDate'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      location: json['location'] as String,
      soilType: json['soilType'] as String,
      healthScore: json['healthScore'] as int,
      phLevel: (json['phLevel'] as num).toDouble(),
      moistureLevel: (json['moistureLevel'] as num).toDouble(),
      nutrientAnalysis: Map<String, double>.from(
        (json['nutrientAnalysis'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      smartRecommendations: List<String>.from(json['smartRecommendations'] as List),
      cropRecommendations: (json['cropRecommendations'] as List)
          .map((e) => CropRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      analysisReport: json['analysisReport'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'userId': userId,
      'imagePath': imagePath,
      'scanDate': scanDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'soilType': soilType,
      'healthScore': healthScore,
      'phLevel': phLevel,
      'moistureLevel': moistureLevel,
      'nutrientAnalysis': nutrientAnalysis,
      'smartRecommendations': smartRecommendations,
      'cropRecommendations': cropRecommendations.map((e) => e.toJson()).toList(),
      'analysisReport': analysisReport,
    };
  }
}

class LeafScanAnalysis {
  final String scanId;
  final String userId;
  final String imagePath;
  final DateTime scanDate;
  final double latitude;
  final double longitude;
  final String location;
  final String cropType;

  // Disease Detection & Analysis
  final String diseaseStatus; // 'Healthy', 'Infected', 'Deficient'
  final String? diseaseName;
  final int healthScore; // 0-100
  final double confidenceScore; // 0-100
  final String? deficiencyType; // e.g., 'Nitrogen deficiency', 'Iron deficiency'
  final List<String> smartRecommendations;
  final List<String> treatmentOptions;
  final String analysisReport;

  LeafScanAnalysis({
    required this.scanId,
    required this.userId,
    required this.imagePath,
    required this.scanDate,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.cropType,
    required this.diseaseStatus,
    this.diseaseName,
    required this.healthScore,
    required this.confidenceScore,
    this.deficiencyType,
    required this.smartRecommendations,
    required this.treatmentOptions,
    required this.analysisReport,
  });

  factory LeafScanAnalysis.fromJson(Map<String, dynamic> json) {
    return LeafScanAnalysis(
      scanId: json['scanId'] as String,
      userId: json['userId'] as String,
      imagePath: json['imagePath'] as String,
      scanDate: DateTime.parse(json['scanDate'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      location: json['location'] as String,
      cropType: json['cropType'] as String,
      diseaseStatus: json['diseaseStatus'] as String,
      diseaseName: json['diseaseName'] as String?,
      healthScore: json['healthScore'] as int,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      deficiencyType: json['deficiencyType'] as String?,
      smartRecommendations: List<String>.from(json['smartRecommendations'] as List),
      treatmentOptions: List<String>.from(json['treatmentOptions'] as List),
      analysisReport: json['analysisReport'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'userId': userId,
      'imagePath': imagePath,
      'scanDate': scanDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'cropType': cropType,
      'diseaseStatus': diseaseStatus,
      'diseaseName': diseaseName,
      'healthScore': healthScore,
      'confidenceScore': confidenceScore,
      'deficiencyType': deficiencyType,
      'smartRecommendations': smartRecommendations,
      'treatmentOptions': treatmentOptions,
      'analysisReport': analysisReport,
    };
  }
}

class CropRecommendation {
  final String cropName;
  final String cropCategory; // 'vegetable', 'grain', 'fruit', 'legume', 'root crop'
  final double suitabilityScore; // 0-100
  final String plantingMonth;
  final String harvestMonth;
  final String? imageUrl;

  CropRecommendation({
    required this.cropName,
    required this.cropCategory,
    required this.suitabilityScore,
    required this.plantingMonth,
    required this.harvestMonth,
    this.imageUrl,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['cropName'] as String,
      cropCategory: json['cropCategory'] as String,
      suitabilityScore: (json['suitabilityScore'] as num).toDouble(),
      plantingMonth: json['plantingMonth'] as String,
      harvestMonth: json['harvestMonth'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'cropCategory': cropCategory,
      'suitabilityScore': suitabilityScore,
      'plantingMonth': plantingMonth,
      'harvestMonth': harvestMonth,
      'imageUrl': imageUrl,
    };
  }
}
