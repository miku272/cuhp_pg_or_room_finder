import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/coordinate.dart';

class PropertyFormData extends Property {
  PropertyFormData({
    super.id,
    super.ownerId,
    super.propertyName,
    super.propertyAddressLine1,
    super.propertyAddressLine2,
    super.propertyVillageOrCity,
    String? propertyPincode,
    super.ownerName,
    super.ownerPhone,
    super.ownerEmail,
    super.propertyType,
    super.propertyGenderAllowance,
    super.rentAgreementAvailable,
    Map<String, double>? coordinates,
    super.distanceFromUniversity,
    super.services = const {
      'food': false,
      'electricity': false,
      'water': false,
      'internet': false,
      'laundry': false,
      'parking': false,
    },
    super.images = const [],
    super.roomIds = const [],
    super.isVerified = false,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  }) : super(
          coordinates: coordinates != null
              ? Coordinate(
                  lat: coordinates['lat'] ?? 32.1726,
                  lng: coordinates['lng'] ?? 76.3617,
                )
              : const Coordinate(lat: 32.1726, lng: 76.3617),
        );

  factory PropertyFormData.fromJson(Map<String, dynamic> json) {
    return PropertyFormData(
      id: json['_id'],
      ownerId: json['owner'],
      propertyName: json['propertyName'],
      propertyAddressLine1: json['propertyAddressLine1'],
      propertyAddressLine2: json['propertyAddressLine2'],
      propertyVillageOrCity: json['propertyVillageOrCity'],
      propertyPincode: json['propertyPincode'],
      ownerName: json['ownerName'],
      ownerPhone: json['ownerPhone'],
      ownerEmail: json['ownerEmail'],
      propertyType: Property.propertyTypeFromString(json['propertyType']),
      propertyGenderAllowance:
          Property.genderAllowanceFromString(json['propertyGenderAllowance']),
      rentAgreementAvailable: json['rentAgreementAvailable'] ?? false,
      coordinates: Map<String, double>.from(json['coordinates'] ?? {}),
      distanceFromUniversity: json['distanceFromUniversity']?.toDouble(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': ownerId,
      'propertyName': propertyName,
      'propertyAddressLine1': propertyAddressLine1,
      'propertyAddressLine2': propertyAddressLine2,
      'propertyVillageOrCity': propertyVillageOrCity,
      'propertyPincode': propertyPincode,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'propertyType': propertyType?.toString().split('.').last,
      'propertyGenderAllowance':
          Property.genderAllowanceToString(propertyGenderAllowance!),
      'rentAgreementAvailable': rentAgreementAvailable,
      'coordinates': coordinates?.toJson(),
      'distanceFromUniversity': distanceFromUniversity,
      'services': services,
      'images': images,
      'rooms': roomIds,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PropertyFormData copyWith({
    String? id,
    String? ownerId,
    String? propertyName,
    String? propertyAddressLine1,
    String? propertyAddressLine2,
    String? propertyVillageOrCity,
    String? propertyPincode,
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
      propertyAddressLine1: propertyAddressLine1 ?? this.propertyAddressLine1,
      propertyAddressLine2: propertyAddressLine2 ?? this.propertyAddressLine2,
      propertyVillageOrCity:
          propertyVillageOrCity ?? this.propertyVillageOrCity,
      propertyPincode: propertyPincode ?? this.propertyPincode,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      propertyType: propertyType ?? this.propertyType,
      propertyGenderAllowance:
          propertyGenderAllowance ?? this.propertyGenderAllowance,
      rentAgreementAvailable:
          rentAgreementAvailable ?? this.rentAgreementAvailable,
      coordinates: coordinates ??
          (this.coordinates != null
              ? {
                  'lat': this.coordinates!.lat,
                  'lng': this.coordinates!.lng,
                }
              : null),
      distanceFromUniversity:
          distanceFromUniversity ?? this.distanceFromUniversity,
      services: services ?? this.services,
      images: images ?? this.images,
      roomIds: roomIds ?? this.roomIds,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
