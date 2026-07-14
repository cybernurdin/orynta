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

  Future<SoilScan> analyzeSoil({String? imagePath, String region = 'Not set'}) async {
    await Future.delayed(const Duration(seconds: 2, milliseconds: 400));

    final soilTypes = SoilType.values;
    final soilType = soilTypes[_random.nextInt(soilTypes.length)];
    final fertility =
        FertilityBand.values[_random.nextInt(FertilityBand.values.length)];
    final confidence = 0.55 + _random.nextDouble() * 0.44;
    final healthScore = switch (fertility) {
      FertilityBand.low => 35 + _random.nextDouble() * 18,
      FertilityBand.medium => 55 + _random.nextDouble() * 18,
      FertilityBand.high => 75 + _random.nextDouble() * 18,
    };
    // NPK is derived from the same fertility band as the health score
    // rather than drawn independently, so a "high fertility" result can't
    // coincidentally show nutrients near the low end — the numbers stay
    // internally consistent scan to scan.
    final npkRange = switch (fertility) {
      FertilityBand.low => (25.0, 45.0),
      FertilityBand.medium => (45.0, 70.0),
      FertilityBand.high => (70.0, 92.0),
    };
    final nitrogen = _jitter(npkRange);
    final phosphorus = _jitter(npkRange);
    final potassium = _jitter(npkRange);
    final phLevel = double.parse((5.8 + _random.nextDouble() * 1.4).toStringAsFixed(1));
    final moisture = double.parse((32 + _random.nextDouble() * 48).toStringAsFixed(0));

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
      phLevel: phLevel,
      moisturePercent: moisture,
      healthScore: double.parse(healthScore.toStringAsFixed(0)),
      nitrogenPercent: nitrogen,
      phosphorusPercent: phosphorus,
      potassiumPercent: potassium,
      region: region,
      smartRecommendations: _smartRecommendationsFor(
        soilType: soilType,
        phLevel: phLevel,
        moisture: moisture,
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
      ),
    );
  }

  double _jitter((double, double) range) =>
      double.parse((range.$1 + _random.nextDouble() * (range.$2 - range.$1)).toStringAsFixed(0));

  List<String> _smartRecommendationsFor({
    required SoilType soilType,
    required double phLevel,
    required double moisture,
    required double nitrogen,
    required double phosphorus,
    required double potassium,
  }) {
    final tips = <String>[];

    if (phLevel < 6.0) {
      tips.add('Soil is acidic (pH ${phLevel.toStringAsFixed(1)}) — apply agricultural lime a few weeks before planting to raise pH toward neutral.');
    } else if (phLevel > 7.0) {
      tips.add('Soil is slightly alkaline (pH ${phLevel.toStringAsFixed(1)}) — incorporate composted organic matter to gradually lower pH.');
    }

    if (nitrogen < 45) {
      tips.add('Nitrogen is low — apply composted manure or a nitrogen-rich fertilizer before planting to support early growth.');
    }
    if (phosphorus < 45) {
      tips.add('Phosphorus is low — a phosphate-based starter fertilizer at planting will help root development.');
    }
    if (potassium < 45) {
      tips.add('Potassium is low — wood ash or a potassium-rich fertilizer will improve disease resistance and yield.');
    }

    if (moisture < 40) {
      tips.add('Soil moisture is on the dry side — mulch around plants and water consistently, especially in the first weeks after planting.');
    } else if (moisture > 70) {
      tips.add('Soil is holding a lot of moisture — ensure good drainage to avoid root rot, especially during heavy rains.');
    }

    switch (soilType) {
      case SoilType.clay:
        tips.add('Clay soil compacts easily — avoid working it while wet and add organic matter to improve drainage over time.');
      case SoilType.sandy:
        tips.add('Sandy soil drains fast and loses nutrients quickly — split fertilizer applications into smaller, more frequent doses.');
      case SoilType.silt:
        tips.add('Silt soil holds nutrients well but can crust — light surface mulching helps maintain structure.');
      case SoilType.mixed:
        tips.add('Mixed soil texture — monitor drainage across the plot, as behavior can vary from one section to another.');
      case SoilType.loam:
        break;
    }

    if (tips.isEmpty) {
      tips.add('Soil conditions are well balanced — maintain current practices and re-test each planting season.');
    }
    return tips.take(5).toList();
  }

  Future<LeafDiagnosis> analyzeLeaf({String? imagePath}) async {
    await Future.delayed(const Duration(seconds: 2, milliseconds: 200));

    final diseases = _leafDiseaseCatalog;
    final entry = diseases[_random.nextInt(diseases.length)];
    final confidence = 0.5 + _random.nextDouble() * 0.49;
    final rounded = double.parse(confidence.toStringAsFixed(2));
    final healthScore = double.parse(
      (entry.healthScoreRange.$1 + _random.nextDouble() * (entry.healthScoreRange.$2 - entry.healthScoreRange.$1))
          .toStringAsFixed(0),
    );

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
      healthScore: healthScore,
      deficiencyType: entry.deficiencyType,
      diseaseStatus: entry.diseaseStatus,
      recommendations: entry.recommendations,
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
      healthScoreRange: (25, 45),
      diseaseStatus: DiseaseStatus.infected,
      recommendations: const [
        'Remove and destroy visibly affected leaves immediately to slow spread.',
        'Apply a copper-based fungicide every 7–10 days until symptoms clear.',
        'Avoid overhead watering — wet foliage speeds up blight spread.',
        'Improve airflow by spacing plants further apart next season.',
      ],
    ),
    _LeafDiseaseEntry(
      name: 'Maize streak virus',
      treatment:
          'Uproot and burn severely affected plants to slow spread. Control leafhopper vectors with a recommended insecticide.',
      safetyNotes: 'Wash hands after handling infected plants. Do not compost removed material near healthy crops.',
      healthScoreRange: (20, 40),
      diseaseStatus: DiseaseStatus.infected,
      recommendations: const [
        'Uproot and burn severely affected plants to slow further spread.',
        'Control leafhopper vectors with a recommended insecticide.',
        'Plant certified virus-resistant maize varieties next season.',
        'Avoid planting new maize directly next to infected plots.',
      ],
    ),
    _LeafDiseaseEntry(
      name: 'Cassava mosaic disease',
      treatment:
          'Use disease-free planting material for the next cycle. Remove and destroy visibly infected stems.',
      safetyNotes: 'No chemical treatment required — this is a viral disease managed through clean planting material.',
      healthScoreRange: (30, 50),
      diseaseStatus: DiseaseStatus.infected,
      recommendations: const [
        'Remove and destroy visibly infected stems to reduce spread.',
        'Source only certified disease-free cuttings for the next planting cycle.',
        'Rotate with a non-host crop for one season if infection is widespread.',
      ],
    ),
    _LeafDiseaseEntry(
      name: 'Fall armyworm damage',
      treatment:
          'Apply a recommended biopesticide early morning or evening. Inspect whorls weekly during the growing season.',
      safetyNotes: 'Re-entry interval: wait 24 hours after spraying before working the field without protective equipment.',
      healthScoreRange: (35, 55),
      diseaseStatus: DiseaseStatus.infected,
      recommendations: const [
        'Apply a recommended biopesticide in the early morning or evening for best effect.',
        'Inspect whorls weekly during the growing season to catch new infestations early.',
        'Encourage natural predators by avoiding broad-spectrum insecticides.',
      ],
    ),
    _LeafDiseaseEntry(
      name: 'Nitrogen deficiency (yellowing leaves)',
      treatment:
          'Apply a nitrogen-rich fertilizer or composted manure. Yellowing should improve within 1–2 weeks.',
      safetyNotes: 'Follow fertilizer label rates — over-application can scorch roots.',
      healthScoreRange: (40, 60),
      diseaseStatus: DiseaseStatus.deficient,
      deficiencyType: 'Nitrogen',
      recommendations: const [
        'Apply a nitrogen-rich fertilizer or composted manure near the root zone.',
        'Interplant with a nitrogen-fixing legume next season to reduce recurrence.',
        'Re-check leaf color in 1–2 weeks after treatment.',
      ],
    ),
    _LeafDiseaseEntry(
      name: 'Healthy — no disease detected',
      treatment: 'No treatment needed. Continue routine monitoring, especially after heavy rain.',
      safetyNotes: 'No safety precautions required.',
      healthScoreRange: (80, 98),
      diseaseStatus: DiseaseStatus.healthy,
      recommendations: const [
        'No treatment needed — continue routine monitoring, especially after heavy rain.',
        'Keep up current watering and fertilizing schedule.',
      ],
    ),
  ];
}

class _LeafDiseaseEntry {
  final String name;
  final String treatment;
  final String safetyNotes;
  final (double, double) healthScoreRange;
  final DiseaseStatus diseaseStatus;
  final String? deficiencyType;
  final List<String> recommendations;
  const _LeafDiseaseEntry({
    required this.name,
    required this.treatment,
    required this.safetyNotes,
    required this.healthScoreRange,
    required this.diseaseStatus,
    required this.recommendations,
    this.deficiencyType,
  });
}
