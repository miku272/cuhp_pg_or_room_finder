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
  final int? numberOfReviews;
  final double? averageRating;
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
    this.numberOfReviews,
    this.averageRating,
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
      case 'rooms':
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

  factory Property.fromJson(Map<String, dynamic> json) {
    // Calculate distance if coordinates are available
    num? calculatedDistance;
    if (json['coordinates'] != null) {
      final coordinate =
          Coordinate.fromJson(json['coordinates'] as Map<String, dynamic>);
      calculatedDistance = coordinate.calculateDistanceFromUniversity();
    }

    return Property(
      id: json['_id'] as String?,
      ownerId: json['owner'] as String?,
      propertyName: json['propertyName'] as String?,
      propertyAddressLine1: json['propertyAddressLine1'] as String?,
      propertyAddressLine2: json['propertyAddressLine2'] as String?,
      propertyVillageOrCity: json['propertyVillageOrCity'] as String?,
      propertyPincode: json['propertyPincode']?.toString(),
      ownerName: json['ownerName'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      pricePerMonth: json['pricePerMonth'] as int?,
      propertyType:
          Property.propertyTypeFromString(json['propertyType'] as String?),
      propertyGenderAllowance: Property.genderAllowanceFromString(
          json['propertyGenderAllowance'] as String?),
      rentAgreementAvailable: json['rentAgreementAvailable'] as bool?,
      coordinates: json['coordinates'] != null
          ? Coordinate.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      distanceFromUniversity: calculatedDistance,
      services: (json['services'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)),
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => image as String)
          .toList(),
      isVerified: json['isVerified'] as bool?,
      isActive: json['isActive'] as bool?,
      numberOfReviews: json['numberOfReviews'] as int?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
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
      'propertyType': Property.propertyTypeToString(propertyType!),
      'propertyGenderAllowance':
          Property.genderAllowanceToString(propertyGenderAllowance!),
      'rentAgreementAvailable': rentAgreementAvailable,
      'coordinates': coordinates?.toJson(),
      'distanceFromUniversity': distanceFromUniversity,
      'services': services,
      'images': images,
      'isVerified': isVerified,
      'isActive': isActive,
      'numberOfReviews': numberOfReviews,
      'averageRating': averageRating,
    };
  }
}
