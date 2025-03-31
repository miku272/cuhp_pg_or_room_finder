import 'dart:math' as math;

class Coordinate {
  static const defaultUniversityCoordinate = Coordinate(
    lat: 32.22449,
    lng: 76.156601,
  );

  final num lat;
  final num lng;

  const Coordinate({
    required this.lat,
    required this.lng,
  });

  factory Coordinate.fromJson(Map<String, num> json) {
    return Coordinate(
      lat: json['lat'] ?? 0.0,
      lng: json['lng'] ?? 0.0,
    );
  }

  Map<String, num> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory Coordinate.fromMap(Map<String, num> map) {
    return Coordinate(
      lat: map['lat'] ?? 0.0,
      lng: map['lng'] ?? 0.0,
    );
  }

  Map<String, num> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  /// Calculates the distance in kilometers between this coordinate and the Central University of Himachal Pradesh default location.
  ///
  /// Uses the Haversine formula to calculate the great-circle distance between two points
  /// on the Earth's surface given their latitude and longitude.
  ///
  /// Returns:
  ///   - A number representing the distance in kilometers, rounded to 2 decimal places.
  ///   - Returns 0 if an error occurs during calculation.
  num calculateDistanceFromUniversity() {
    return _calculateDistance(
      lat,
      lng,
      defaultUniversityCoordinate.lat,
      defaultUniversityCoordinate.lng,
    );
  }

  static num _calculateDistance(
    num lat1,
    num lon1,
    num lat2,
    num lon2,
  ) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = R * c;

    return double.parse(distance.toStringAsFixed(2));
  }

  static num _toRad(num degrees) => degrees * (math.pi / 180);
}
