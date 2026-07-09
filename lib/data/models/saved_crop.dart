/// A crop recommendation the farmer bookmarked from a soil scan result,
/// kept independently of the scan so it survives even if the scan is
/// later deleted.
class SavedCrop {
  final String id;
  final String cropName;
  final String rationale;
  final DateTime savedAt;

  const SavedCrop({
    required this.id,
    required this.cropName,
    required this.rationale,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'rationale': rationale,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedCrop.fromJson(Map<String, dynamic> json) => SavedCrop(
        id: json['id'] as String,
        cropName: json['cropName'] as String,
        rationale: json['rationale'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}
