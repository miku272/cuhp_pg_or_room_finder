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
    super.propertyPincode,
    super.ownerName,
    super.ownerPhone,
    super.ownerEmail,
    super.pricePerMonth,
    super.propertyType,
    super.propertyGenderAllowance,
    super.rentAgreementAvailable,
    super.coordinates = const Coordinate(coordinates: [76.3617, 32.1726]),
    super.distanceFromUniversity,
    super.services = const {
      'food': false,
      'electricity': false,
      'water': false,
      'internet': false,
      'laundry': false,
      'parking': false,
    },
    super.images,
    super.isVerified = false,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

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
      pricePerMonth: json['pricePerMonth'],
      propertyType: Property.propertyTypeFromString(json['propertyType']),
      propertyGenderAllowance:
          Property.genderAllowanceFromString(json['propertyGenderAllowance']),
      rentAgreementAvailable: json['rentAgreementAvailable'] ?? false,
      coordinates: Coordinate(
        coordinates: json['coordinates']['coordinates'],
      ),
      distanceFromUniversity: json['distanceFromUniversity']?.toDouble(),
      services: Map<String, bool>.from(json['services'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
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
      'pricePerMonth': pricePerMonth,
      'propertyType': propertyType.toString().split('.').last,
      'propertyGenderAllowance':
          Property.genderAllowanceToString(propertyGenderAllowance!),
      'rentAgreementAvailable': rentAgreementAvailable,
      'coordinates': coordinates?.toJson(),
      'distanceFromUniversity': distanceFromUniversity,
      'services': services,
      'images': images,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
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
    int? pricePerMonth,
    PropertyType? propertyType,
    GenderAllowance? propertyGenderAllowance,
    bool? rentAgreementAvailable,
    Coordinate? coordinates,
    num? distanceFromUniversity,
    Map<String, bool>? services,
    List<String>? images,
    bool? isVerified,
    bool? isActive,
    bool? isSaved,
    int? numberOfReviews,
    double? averageRating,
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
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      propertyType: propertyType ?? this.propertyType,
      propertyGenderAllowance:
          propertyGenderAllowance ?? this.propertyGenderAllowance,
      rentAgreementAvailable:
          rentAgreementAvailable ?? this.rentAgreementAvailable,
      coordinates: coordinates ?? this.coordinates,
      distanceFromUniversity:
          distanceFromUniversity ?? this.distanceFromUniversity,
      services: services ?? this.services,
      images: images ?? this.images,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
