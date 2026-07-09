/// Mirrors the `WeatherAdvisory` entity in Orynta_SRS.md §7.
/// FR-3.3: template-based translation of forecast into a concrete
/// farmer-facing action sentence.
enum AdvisoryWindow { week, month, season }

class WeatherAdvisory {
  final String id;
  final String region;
  final AdvisoryWindow window;
  final DateTime issuedAt;
  final String headline;
  final String advisoryText;
  final double highC;
  final double lowC;
  final int rainChancePercent;

  const WeatherAdvisory({
    required this.id,
    required this.region,
    required this.window,
    required this.issuedAt,
    required this.headline,
    required this.advisoryText,
    required this.highC,
    required this.lowC,
    required this.rainChancePercent,
  });
}
