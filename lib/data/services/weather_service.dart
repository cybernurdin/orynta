import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_advisory.dart';

class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String description;
  final String condition; // 'sunny', 'cloudy', 'rainy', 'snowy'
  final double humidity;
  final double windSpeed;
  final double rainfall; // mm
  final DateTime lastUpdated;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
    required this.lastUpdated,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      description: json['description'] as String,
      condition: json['condition'] as String,
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      rainfall: (json['rainfall'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'description': description,
      'condition': condition,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainfall': rainfall,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class WeatherForecast {
  final String date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String description;
  final double chanceOfRain;

  WeatherForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.description,
    required this.chanceOfRain,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: json['date'] as String,
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String,
      chanceOfRain: (json['chanceOfRain'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'tempMax': tempMax,
      'tempMin': tempMin,
      'condition': condition,
      'description': description,
      'chanceOfRain': chanceOfRain,
    };
  }
}

/// Stands in for the met-API integration + template translation engine
/// in Orynta_SRS.md §5.4 / FR-3.1–3.3. Returns deterministic content so
/// the home-screen demo is stable; swap the body for a real forecast
/// call + template fill without touching callers.
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();

  factory WeatherService() {
    return _instance;
  }

  WeatherService._internal();

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

  // Get current weather by coordinates
  Future<WeatherData?> getWeatherByCoordinates(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&temperature_unit=celsius',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        return WeatherData(
          location: '$latitude, $longitude',
          temperature: (current['temperature_2m'] as num).toDouble(),
          feelsLike: (current['temperature_2m'] as num).toDouble(),
          description: _getWeatherDescription(current['weather_code']),
          condition: _getWeatherCondition(current['weather_code']),
          humidity: (current['relative_humidity_2m'] as num).toDouble(),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
          rainfall: 0.0,
          lastUpdated: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  // Get weather forecast
  Future<List<WeatherForecast>> getWeatherForecast(
    double latitude,
    double longitude,
    int days,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_sum&temperature_unit=celsius&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final daily = data['daily'];
        final datesList = daily['time'] as List;
        final temps_max = daily['temperature_2m_max'] as List;
        final temps_min = daily['temperature_2m_min'] as List;
        final weather_codes = daily['weather_code'] as List;
        final precipitations = daily['precipitation_sum'] as List? ?? [];

        List<WeatherForecast> forecasts = [];
        for (int i = 0; i < (days.clamp(0, datesList.length)); i++) {
          forecasts.add(
            WeatherForecast(
              date: datesList[i] as String,
              tempMax: (temps_max[i] as num).toDouble(),
              tempMin: (temps_min[i] as num).toDouble(),
              condition: _getWeatherCondition(weather_codes[i]),
              description: _getWeatherDescription(weather_codes[i]),
              chanceOfRain: i < precipitations.length ? (precipitations[i] as num).toDouble() : 0,
            ),
          );
        }
        return forecasts;
      }
      return [];
    } catch (e) {
      print('Error fetching forecast: $e');
      return [];
    }
  }

  String _getWeatherCondition(int weatherCode) {
    if (weatherCode == 0 || weatherCode == 1) return 'sunny';
    if (weatherCode == 2 || weatherCode == 3) return 'cloudy';
    if (weatherCode >= 45 && weatherCode <= 48) return 'foggy';
    if (weatherCode >= 51 && weatherCode <= 67) return 'rainy';
    if (weatherCode >= 71 && weatherCode <= 85) return 'snowy';
    if (weatherCode >= 80 && weatherCode <= 82) return 'rainy';
    if (weatherCode >= 85 && weatherCode <= 86) return 'snowy';
    if (weatherCode >= 90 && weatherCode <= 99) return 'thunderstorm';
    return 'cloudy';
  }

  String _getWeatherDescription(int weatherCode) {
    const descriptions = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Foggy',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      71: 'Slight snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with slight hail',
      99: 'Thunderstorm with heavy hail',
    };
    return descriptions[weatherCode] ?? 'Unknown';
  }
}
