import '../models/planting_guide_entry.dart';

/// Seasonal planting/harvest reference, covering the crops that
/// [InferenceService]'s soil recommendations can surface. Static content
/// today; a real version would be agronomist-authored and versioned per
/// Orynta_SRS.md §5.3 ("rules/knowledge-base layer... versioned as content").
class PlantingGuideService {
  static const List<PlantingGuideEntry> _entries = [
    PlantingGuideEntry(
      cropName: 'Maize',
      bestPlantingSeason: 'Start of rainy season (March–April)',
      growthDuration: '90–120 days',
      waterNeeds: 'Moderate — sensitive to drought at tasseling',
      commonThreats: 'Fall armyworm, maize streak virus, leaf blight',
      harvestNotes: 'Harvest when husks turn brown and kernels are hard.',
    ),
    PlantingGuideEntry(
      cropName: 'Rice',
      bestPlantingSeason: 'Onset of rains, into standing water where possible',
      growthDuration: '100–150 days',
      waterNeeds: 'High — needs consistent flooding or moist soil',
      commonThreats: 'Rice blast, stem borers, birds at grain-fill',
      harvestNotes: 'Harvest when 80–85% of grains turn golden.',
    ),
    PlantingGuideEntry(
      cropName: 'Cassava',
      bestPlantingSeason: 'Early rainy season, from healthy stem cuttings',
      growthDuration: '9–18 months depending on variety',
      waterNeeds: 'Low — tolerant of dry spells once established',
      commonThreats: 'Cassava mosaic disease, mealybugs',
      harvestNotes: 'Dig carefully to avoid damaging tubers; harvest on dry days.',
    ),
    PlantingGuideEntry(
      cropName: 'Groundnut',
      bestPlantingSeason: 'Start of rains on well-drained sandy soil',
      growthDuration: '90–120 days',
      waterNeeds: 'Moderate — avoid waterlogging',
      commonThreats: 'Leaf spot, aphids, rosette virus',
      harvestNotes: 'Harvest when leaves yellow and pods rattle when shaken.',
    ),
    PlantingGuideEntry(
      cropName: 'Watermelon',
      bestPlantingSeason: 'Warm, dry period with irrigation access',
      growthDuration: '80–100 days',
      waterNeeds: 'High during fruit development, reduce near harvest',
      commonThreats: 'Fusarium wilt, fruit flies, powdery mildew',
      harvestNotes: 'Ready when the tendril nearest the fruit dries out.',
    ),
    PlantingGuideEntry(
      cropName: 'Tomato',
      bestPlantingSeason: 'Nursery start 4–6 weeks before rains, transplant after',
      growthDuration: '60–90 days after transplanting',
      waterNeeds: 'Moderate, consistent — avoid wetting foliage',
      commonThreats: 'Late blight, whiteflies, blossom-end rot',
      harvestNotes: 'Pick when fruit reaches full color for the variety.',
    ),
    PlantingGuideEntry(
      cropName: 'Beans',
      bestPlantingSeason: 'Start of rains, well-drained soil',
      growthDuration: '60–90 days',
      waterNeeds: 'Moderate — sensitive to both drought and waterlogging',
      commonThreats: 'Bean rust, aphids, root rot',
      harvestNotes: 'Harvest pods when dry and rattling for grain; earlier for green beans.',
    ),
    PlantingGuideEntry(
      cropName: 'Cabbage',
      bestPlantingSeason: 'Cooler months, nursery-raised then transplanted',
      growthDuration: '70–100 days after transplanting',
      waterNeeds: 'High and consistent, especially during head formation',
      commonThreats: 'Diamondback moth, cabbage aphids, black rot',
      harvestNotes: 'Harvest when heads feel firm and solid when pressed.',
    ),
    PlantingGuideEntry(
      cropName: 'Onion',
      bestPlantingSeason: 'Dry season with irrigation, from nursery transplants',
      growthDuration: '100–150 days',
      waterNeeds: 'Moderate, reduce sharply near maturity to cure bulbs',
      commonThreats: 'Thrips, purple blotch, downy mildew',
      harvestNotes: 'Harvest when tops yellow and fall over; cure in shade before storage.',
    ),
    PlantingGuideEntry(
      cropName: 'Plantain',
      bestPlantingSeason: 'Start of rains, from healthy suckers',
      growthDuration: '10–14 months to first harvest',
      waterNeeds: 'High and consistent — sensitive to prolonged dry spells',
      commonThreats: 'Black sigatoka, weevils, nematodes',
      harvestNotes: 'Harvest when fruit fingers are full but still green-mature.',
    ),
  ];

  Future<List<PlantingGuideEntry>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _entries;
  }
}
