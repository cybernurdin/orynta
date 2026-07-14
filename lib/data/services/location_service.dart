import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  // Check and request location permissions
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.whileInUse || result == LocationPermission.always;
    } else if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return false;
    }
    return true;
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Get location as a readable address (you'd typically use geocoding package)
  Future<String> getLocationAddress(double latitude, double longitude) async {
    // This would typically use a geocoding service
    // For now, returning coordinates as string
    return '$latitude, $longitude';
  }

  /// Cameroon's 10 regions, approximated by their rough geographic center.
  /// A real reverse-geocoding API is out of scope for a no-backend demo —
  /// this nearest-center lookup is enough to turn a GPS fix into a
  /// meaningful region name instead of raw coordinates.
  static const Map<String, (double, double)> _regionCenters = {
    'Adamawa Region': (7.3, 13.6),
    'Centre Region': (4.7, 11.9),
    'East Region': (4.4, 14.4),
    'Far North Region': (10.6, 14.3),
    'Littoral Region': (4.1, 9.7),
    'North Region': (8.6, 13.7),
    'Northwest Region': (6.0, 10.2),
    'South Region': (2.9, 11.3),
    'Southwest Region': (4.9, 9.3),
    'West Region': (5.5, 10.4),
  };

  String resolveRegionName(double latitude, double longitude) {
    var closest = 'West Region';
    var closestDistance = double.infinity;
    for (final entry in _regionCenters.entries) {
      final dLat = latitude - entry.value.$1;
      final dLng = longitude - entry.value.$2;
      final distance = dLat * dLat + dLng * dLng;
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = entry.key;
      }
    }
    return closest;
  }

  // Stream location updates
  Stream<Position> getLocationStream({
    int distanceFilter = 10, // meters
    int intervalDuration = 5000, // milliseconds
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        timeLimit: Duration(milliseconds: intervalDuration),
      ),
    );
  }
}
