import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/coordinate.dart';

class PropertyListingModel extends Property {
  PropertyListingModel({
    required String super.id,
    required String super.ownerId,
    required String super.propertyName,
    required String super.propertyAddressLine1,
    super.propertyAddressLine2,
    required String super.propertyVillageOrCity,
    required String super.propertyPincode,
    required String super.ownerName,
    required String super.ownerPhone,
    required String super.ownerEmail,
    required int super.pricePerMonth,
    required PropertyType super.propertyType,
    required GenderAllowance super.propertyGenderAllowance,
    required bool super.rentAgreementAvailable,
    required Coordinate super.coordinates,
    required num super.distanceFromUniversity,
    required Map<String, bool> super.services,
    required List<String> super.images,
    required List<String> super.roomIds,
    required bool super.isVerified,
    required bool super.isActive,
    required DateTime super.createdAt,
    required DateTime super.updatedAt,
  });

  factory PropertyListingModel.fromJson(Map<String, dynamic> json) {
    return PropertyListingModel(
      id: json['_id'] ?? '',
      ownerId: json['owner'] ?? '',
      propertyName: json['propertyName'] ?? '',
      propertyAddressLine1: json['propertyAddressLine1'] ?? '',
      propertyAddressLine2: json['propertyAddressLine2'],
      propertyVillageOrCity: json['propertyVillageOrCity'] ?? '',
      propertyPincode: json['propertyPincode'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      pricePerMonth: json['pricePerMonth'] ?? 0,
      propertyType: Property.propertyTypeFromString(json['propertyType']),
      propertyGenderAllowance:
          Property.genderAllowanceFromString(json['propertyGenderAllowance']),
      rentAgreementAvailable: json['rentAgreementAvailable'] ?? false,
      coordinates: Coordinate.fromJson(
          Map<String, num>.from(json['coordinates'] ?? {})),
      distanceFromUniversity: json['distanceFromUniversity'] ?? 0.0,
      services: Map<String, bool>.from(json['services'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      roomIds: List<String>.from(json['rooms'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
}
