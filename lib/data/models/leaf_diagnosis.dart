/// Mirrors the `LeafDiagnosis` entity in Orynta_SRS.md §7.
/// FR-2.3: confidence below threshold auto-creates an escalation case
/// rather than ever being shown as a settled fact.
enum EscalationStatus { none, pending, resolved }

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
      );
}
