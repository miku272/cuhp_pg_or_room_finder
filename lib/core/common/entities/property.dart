import './coordinate.dart';

enum PropertyType { pg, room }

enum GenderAllowance {
  boys,
  girls,
  coEd // Note: matches backend 'co-ed'
}

class Property {
  final String? id;
  final String? ownerId;
  final String? propertyName;
  final String? propertyAddressLine1;
  final String? propertyAddressLine2;
  final String? propertyVillageOrCity;
  final String? propertyPincode; // Can be num or String
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final int? pricePerMonth;
  final PropertyType? propertyType;
  final GenderAllowance? propertyGenderAllowance;
  final bool? rentAgreementAvailable;
  final Coordinate? coordinates;
  final num? distanceFromUniversity;
  final Map<String, bool>? services;
  final List<String>? images;
  final bool? isVerified;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Property({
    this.id,
    required this.ownerId,
    required this.propertyName,
    required this.propertyAddressLine1,
    this.propertyAddressLine2,
    required this.propertyVillageOrCity,
    required this.propertyPincode,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.pricePerMonth,
    required this.propertyType,
    required this.propertyGenderAllowance,
    required this.rentAgreementAvailable,
    required this.coordinates,
    this.distanceFromUniversity,
    this.services,
    this.images,
    this.isVerified,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  static String propertyTypeToString(PropertyType value) {
    switch (value) {
      case PropertyType.pg:
        return 'pg';
      case PropertyType.room:
        return 'room';
    }
  }

  static PropertyType propertyTypeFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pg':
        return PropertyType.pg;
      case 'room':
      default:
        return PropertyType.room;
    }
  }

  static GenderAllowance genderAllowanceFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'boys':
        return GenderAllowance.boys;
      case 'girls':
        return GenderAllowance.girls;
      case 'co-ed':
      default:
        return GenderAllowance.coEd;
    }
  }

  static String genderAllowanceToString(GenderAllowance value) {
    switch (value) {
      case GenderAllowance.coEd:
        return 'co-ed';
      default:
        return value.toString().split('.').last;
    }
  }
}
