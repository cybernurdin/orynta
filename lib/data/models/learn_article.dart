/// A Learn & Resources article. Static seeded content today, following
/// the same pattern as [PlantingGuideEntry] — a real version would be
/// agronomist-authored and versioned.
class LearnArticle {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String body;
  final int readMinutes;

  const LearnArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.readMinutes,
  });
}
