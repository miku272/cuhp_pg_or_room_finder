import 'dart:math' as math;

class Coordinate {
  static const defaultUniversityCoordinate = {
    'lat': 32.22449,
    'lng': 76.156601
  };

  final double lat;
  final double lng;

  const Coordinate({
    required this.lat,
    required this.lng,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      lat: json['lat'] ?? 0.0,
      lng: json['lng'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory Coordinate.fromMap(Map<String, dynamic> map) {
    return Coordinate(
      lat: map['lat'] ?? 0.0,
      lng: map['lng'] ?? 0.0,
    );
  }

  Map<String, double> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  double calculateDistanceFromUniversity() {
    return _calculateDistance(
      lat,
      lng,
      defaultUniversityCoordinate['lat']!,
      defaultUniversityCoordinate['lng']!,
    );
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
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

  static double _toRad(double degrees) => degrees * (math.pi / 180);
}
