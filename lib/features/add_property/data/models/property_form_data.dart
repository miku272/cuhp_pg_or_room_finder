enum PropertyType { building, flat }

enum GenderAllowance { boys, girls, coEd }

class PropertyFormData {
  final String? id; // MongoDB ObjectId as String
  final String? ownerId; // User/Owner reference
  final String propertyName;
  final String propertyAddress;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final PropertyType propertyType;
  final GenderAllowance propertyGenderAllowance;
  final bool rentAgreementAvailable;
  final Map<String, double> coordinates;
  final double? distanceFromUniversity;
  final Map<String, bool> services;
  final List<String> images;
  final List<String> roomIds; // Room references
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PropertyFormData({
    this.id,
    this.ownerId,
    this.propertyName = '',
    this.propertyAddress = '',
    this.ownerName = '',
    this.ownerPhone = '',
    this.ownerEmail = '',
    this.propertyType = PropertyType.building,
    this.propertyGenderAllowance = GenderAllowance.coEd,
    this.rentAgreementAvailable = false,
    this.coordinates = const {
      'lat': 32.1726,
      'lng': 76.3617
    }, // Default to university coordinates
    this.distanceFromUniversity,
    this.services = const {
      'food': false,
      'electricity': false,
      'water': false,
      'internet': false,
      'laundry': false,
      'parking': false,
    },
    this.images = const [],
    this.roomIds = const [],
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'propertyName': propertyName,
      'propertyAddress': propertyAddress,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'propertyType': propertyType,
      'propertyGenderAllowance': propertyGenderAllowance,
      'rentAgreementAvailable': rentAgreementAvailable,
      'coordinates': coordinates,
      'distanceFromUniversity': distanceFromUniversity,
      'services': services,
      'images': images,
      'roomIds': roomIds,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Factory constructor to create object from JSON
  factory PropertyFormData.fromJson(Map<String, dynamic> json) {
    return PropertyFormData(
      id: json['_id'],
      ownerId: json['owner'],
      propertyName: json['propertyName'] ?? '',
      propertyAddress: json['propertyAddress'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      propertyType: json['propertyType'] ?? 'building',
      propertyGenderAllowance: json['propertyGenderAllowance'] ?? 'co-ed',
      rentAgreementAvailable: json['rentAgreementAvailable'] ?? false,
      coordinates: Map<String, double>.from(json['coordinates'] ?? {}),
      distanceFromUniversity: json['distanceFromUniversity'],
      services: Map<String, bool>.from(json['services'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      roomIds: List<String>.from(json['rooms'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  PropertyFormData copyWith({
    String? id,
    String? ownerId,
    String? propertyName,
    String? propertyAddress,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    PropertyType? propertyType,
    GenderAllowance? propertyGenderAllowance,
    bool? rentAgreementAvailable,
    Map<String, double>? coordinates,
    double? distanceFromUniversity,
    Map<String, bool>? services,
    List<String>? images,
    List<String>? roomIds,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyFormData(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      propertyName: propertyName ?? this.propertyName,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      propertyType: propertyType ?? this.propertyType,
      propertyGenderAllowance:
          propertyGenderAllowance ?? this.propertyGenderAllowance,
      rentAgreementAvailable:
          rentAgreementAvailable ?? this.rentAgreementAvailable,
      coordinates: coordinates ?? Map<String, double>.from(this.coordinates),
      distanceFromUniversity:
          distanceFromUniversity ?? this.distanceFromUniversity,
      services: services ?? Map<String, bool>.from(this.services),
      images: images ?? List<String>.from(this.images),
      roomIds: roomIds ?? List<String>.from(this.roomIds),
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
