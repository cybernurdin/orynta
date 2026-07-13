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
