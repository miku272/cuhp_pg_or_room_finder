import 'dart:math' as math;

class Coordinate {
  static const defaultUniversityCoordinate = Coordinate(
    coordinates: [76.156601, 32.22449],
  );

  final String type;
  final List<num> coordinates; // [lng, lat]

  const Coordinate({
    this.type = 'Point',
    required this.coordinates,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      type: 'Point',
      coordinates: List<num>.from(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Point',
      'coordinates': coordinates,
    };
  }

  factory Coordinate.fromMap(Map<String, dynamic> map) {
    return Coordinate(
      type: 'Point',
      coordinates: List<num>.from(map['coordinates']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': 'Point',
      'coordinates': coordinates,
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
      coordinates[1],
      coordinates[0],
      defaultUniversityCoordinate.coordinates[1],
      defaultUniversityCoordinate.coordinates[0],
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
