import '../models/weather_advisory.dart';

/// Stands in for the met-API integration + template translation engine
/// in Orynta_SRS.md §5.4 / FR-3.1–3.3. Returns deterministic content so
/// the home-screen demo is stable; swap the body for a real forecast
/// call + template fill without touching callers.
class WeatherService {
  Future<WeatherAdvisory> getWeeklyAdvisory({required String region}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return WeatherAdvisory(
      id: 'wx_${DateTime.now().millisecondsSinceEpoch}',
      region: region,
      window: AdvisoryWindow.week,
      issuedAt: DateTime.now(),
      headline: 'Good window to spray Thursday',
      advisoryText:
          'Dry conditions expected through Thursday — a good window for spraying or planting. '
          'Heavy rain likely from Saturday, so plan harvesting or fertilizer application before then.',
      highC: 29,
      lowC: 19,
      rainChancePercent: 65,
    );
  }

  Future<WeatherAdvisory> getMonthlyOutlook({required String region}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return WeatherAdvisory(
      id: 'wx_month_${DateTime.now().millisecondsSinceEpoch}',
      region: region,
      window: AdvisoryWindow.month,
      issuedAt: DateTime.now(),
      headline: 'Rainy season onset on track',
      advisoryText:
          'Rainfall this month is expected close to seasonal average. Good month to prepare land '
          'and plant maize and tomato in well-drained plots.',
      highC: 28,
      lowC: 18,
      rainChancePercent: 55,
    );
  }
}
