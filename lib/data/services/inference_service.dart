import 'dart:math';
import '../models/leaf_diagnosis.dart';
import '../models/soil_scan.dart';

/// Stands in for the cloud AI/ML service described in Orynta_SRS.md §5.
///
/// The soil and leaf classifiers described there (MobileNetV3/EfficientNet-Lite
/// transfer learning, fine-tuned on locally-collected samples) are not trained
/// yet — this mock returns plausible, varied results on the same contract the
/// real inference API will return, so the rest of the app (confidence badges,
/// escalation routing, crop ranking, offline queueing) is fully wired and
/// swaps to a live endpoint with only this file changing.
class InferenceService {
  static const String soilModelVersion = 'soil-mock-v0.1';
  static const String leafModelVersion = 'leaf-mock-v0.1';

  /// FR-2.3: confidence below this routes to the agronomist queue instead
  /// of being shown as a settled fact. `[DECISION NEEDED in SRS: default 70%]`.
  static const double escalationThreshold = 0.70;

  final Random _random = Random();

  Future<SoilScan> analyzeSoil({String? imagePath}) async {
    await Future.delayed(const Duration(seconds: 2, milliseconds: 400));

    final soilTypes = SoilType.values;
    final soilType = soilTypes[_random.nextInt(soilTypes.length)];
    final fertility =
        FertilityBand.values[_random.nextInt(FertilityBand.values.length)];
    final confidence = 0.55 + _random.nextDouble() * 0.44;

    return SoilScan(
      id: 'scan_${DateTime.now().microsecondsSinceEpoch}',
      source: SoilScanSource.photo,
      capturedAt: DateTime.now(),
      soilType: soilType,
      fertilityBand: fertility,
      confidence: double.parse(confidence.toStringAsFixed(2)),
      modelVersion: soilModelVersion,
      imagePath: imagePath,
      recommendations: _recommendationsFor(soilType, fertility),
    );
  }

  Future<LeafDiagnosis> analyzeLeaf({String? imagePath}) async {
    await Future.delayed(const Duration(seconds: 2, milliseconds: 200));

    final diseases = _leafDiseaseCatalog;
    final entry = diseases[_random.nextInt(diseases.length)];
    final confidence = 0.5 + _random.nextDouble() * 0.49;
    final rounded = double.parse(confidence.toStringAsFixed(2));

    return LeafDiagnosis(
      id: 'leaf_${DateTime.now().microsecondsSinceEpoch}',
      capturedAt: DateTime.now(),
      imagePath: imagePath,
      predictedClass: entry.name,
      confidence: rounded,
      modelVersion: leafModelVersion,
      treatment: entry.treatment,
      safetyNotes: entry.safetyNotes,
      escalationStatus: rounded < escalationThreshold
          ? EscalationStatus.pending
          : EscalationStatus.none,
    );
  }

  List<CropRecommendation> _recommendationsFor(
    SoilType soilType,
    FertilityBand fertility,
  ) {
    final byType = <SoilType, List<String>>{
      SoilType.clay: ['Maize', 'Rice', 'Cassava'],
      SoilType.sandy: ['Groundnut', 'Cassava', 'Watermelon'],
      SoilType.loam: ['Tomato', 'Maize', 'Beans'],
      SoilType.silt: ['Tomato', 'Cabbage', 'Onion'],
      SoilType.mixed: ['Cassava', 'Plantain', 'Maize'],
    };
    final crops = byType[soilType]!;
    final fertilityNote = switch (fertility) {
      FertilityBand.high => 'soil fertility is high, so yields should respond well to normal input levels.',
      FertilityBand.medium => 'soil fertility is moderate — a balanced fertilizer application is recommended before planting.',
      FertilityBand.low => 'soil fertility is low — plan for soil amendment (compost or fertilizer) before this crop will perform well.',
    };
    return List.generate(crops.length, (i) {
      return CropRecommendation(
        cropName: crops[i],
        rank: i + 1,
        rationale:
            '${crops[i]} suits ${_soilTypeLabel(soilType)} soil; $fertilityNote',
      );
    });
  }

  String _soilTypeLabel(SoilType type) => switch (type) {
        SoilType.clay => 'clay',
        SoilType.sandy => 'sandy',
        SoilType.loam => 'loam',
        SoilType.silt => 'silt',
        SoilType.mixed => 'mixed',
      };

  static final List<_LeafDiseaseEntry> _leafDiseaseCatalog = [
    _LeafDiseaseEntry(
      name: 'Late blight (tomato)',
      treatment:
          'Remove and destroy affected leaves. Apply a copper-based fungicide every 7–10 days until symptoms clear.',
      safetyNotes: 'Wear gloves and a mask when spraying. Keep children and animals away for 24 hours after application.',
    ),
    _LeafDiseaseEntry(
      name: 'Maize streak virus',
      treatment:
          'Uproot and burn severely affected plants to slow spread. Control leafhopper vectors with a recommended insecticide.',
      safetyNotes: 'Wash hands after handling infected plants. Do not compost removed material near healthy crops.',
    ),
    _LeafDiseaseEntry(
      name: 'Cassava mosaic disease',
      treatment:
          'Use disease-free planting material for the next cycle. Remove and destroy visibly infected stems.',
      safetyNotes: 'No chemical treatment required — this is a viral disease managed through clean planting material.',
    ),
    _LeafDiseaseEntry(
      name: 'Fall armyworm damage',
      treatment:
          'Apply a recommended biopesticide early morning or evening. Inspect whorls weekly during the growing season.',
      safetyNotes: 'Re-entry interval: wait 24 hours after spraying before working the field without protective equipment.',
    ),
    _LeafDiseaseEntry(
      name: 'Healthy — no disease detected',
      treatment: 'No treatment needed. Continue routine monitoring, especially after heavy rain.',
      safetyNotes: 'No safety precautions required.',
    ),
  ];
}

class _LeafDiseaseEntry {
  final String name;
  final String treatment;
  final String safetyNotes;
  const _LeafDiseaseEntry({
    required this.name,
    required this.treatment,
    required this.safetyNotes,
  });
}
