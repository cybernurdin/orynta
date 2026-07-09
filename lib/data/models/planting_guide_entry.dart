/// Static reference content for the seasonal planting guide — not
/// farmer-generated data, so it isn't persisted through AppRepository.
class PlantingGuideEntry {
  final String cropName;
  final String bestPlantingSeason;
  final String growthDuration;
  final String waterNeeds;
  final String commonThreats;
  final String harvestNotes;

  const PlantingGuideEntry({
    required this.cropName,
    required this.bestPlantingSeason,
    required this.growthDuration,
    required this.waterNeeds,
    required this.commonThreats,
    required this.harvestNotes,
  });
}
