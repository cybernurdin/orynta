/// Mirrors the `LeafDiagnosis` entity in Orynta_SRS.md §7.
/// FR-2.3: confidence below threshold auto-creates an escalation case
/// rather than ever being shown as a settled fact.
enum EscalationStatus { none, pending, resolved }

/// Coarse leaf-health classification driving the result screen's status
/// treatment — parallel to `FertilityBand` on the soil side.
enum DiseaseStatus { healthy, infected, deficient }

class LeafDiagnosis {
  final String id;
  final DateTime capturedAt;
  final String? imagePath;
  final String predictedClass;
  final double confidence;
  final String modelVersion;
  final String treatment;
  final String safetyNotes;
  final EscalationStatus escalationStatus;
  final double healthScore;
  final String? deficiencyType;
  final DiseaseStatus diseaseStatus;
  final List<String> recommendations;

  const LeafDiagnosis({
    required this.id,
    required this.capturedAt,
    required this.predictedClass,
    required this.confidence,
    required this.modelVersion,
    required this.treatment,
    required this.safetyNotes,
    required this.escalationStatus,
    this.imagePath,
    this.healthScore = 70,
    this.deficiencyType,
    this.diseaseStatus = DiseaseStatus.healthy,
    this.recommendations = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'capturedAt': capturedAt.toIso8601String(),
        'imagePath': imagePath,
        'predictedClass': predictedClass,
        'confidence': confidence,
        'modelVersion': modelVersion,
        'treatment': treatment,
        'safetyNotes': safetyNotes,
        'escalationStatus': escalationStatus.name,
        'healthScore': healthScore,
        'deficiencyType': deficiencyType,
        'diseaseStatus': diseaseStatus.name,
        'recommendations': recommendations,
      };

  factory LeafDiagnosis.fromJson(Map<String, dynamic> json) => LeafDiagnosis(
        id: json['id'] as String,
        capturedAt: DateTime.parse(json['capturedAt'] as String),
        imagePath: json['imagePath'] as String?,
        predictedClass: json['predictedClass'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        modelVersion: json['modelVersion'] as String,
        treatment: json['treatment'] as String,
        safetyNotes: json['safetyNotes'] as String,
        escalationStatus:
            EscalationStatus.values.byName(json['escalationStatus'] as String),
        healthScore: (json['healthScore'] as num?)?.toDouble() ?? ((json['confidence'] as num).toDouble() * 100),
        deficiencyType: json['deficiencyType'] as String?,
        diseaseStatus: json['diseaseStatus'] != null
            ? DiseaseStatus.values.byName(json['diseaseStatus'] as String)
            : (predictedClassLooksHealthy(json['predictedClass'] as String) ? DiseaseStatus.healthy : DiseaseStatus.infected),
        recommendations: (json['recommendations'] as List?)?.map((e) => e as String).toList() ??
            [json['treatment'] as String],
      );

  static bool predictedClassLooksHealthy(String predictedClass) =>
      predictedClass.toLowerCase().contains('healthy');
}
