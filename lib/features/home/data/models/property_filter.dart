import 'package:flutter/foundation.dart';

import '../../../../core/common/entities/property.dart';

@immutable
final class PropertyFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? maxDistance; // Max distance from university in KM
  final PropertyType? propertyType; // 'pg', 'room'
  final GenderAllowance? genderAllowance; // 'boys', 'girls', 'co-ed'
  final List<String>? services; // ['food', 'water', 'internet']
  final bool? rentAgreementAvailable;
  final bool? isVerified;
  final double? nearMeLat;
  final double? nearMeLng;
  final double? nearMeRadius; // Default radius in km for near me
  final String?
      sortBy; // 'distance', 'price_asc', 'price_desc', 'createdAt_desc'

  const PropertyFilter({
    this.minPrice,
    this.maxPrice,
    this.maxDistance,
    this.propertyType,
    this.genderAllowance,
    this.services,
    this.rentAgreementAvailable,
    this.isVerified,
    this.nearMeLat,
    this.nearMeLng,
    this.nearMeRadius,
    this.sortBy,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    if (minPrice != null) params['minPrice'] = minPrice!.round().toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice!.round().toString();
    if (maxDistance != null) params['maxDistance'] = maxDistance!.toString();
    // Convert enums to strings for the API call
    if (propertyType != null) {
      params['propertyType'] = Property.propertyTypeToString(propertyType!);
    }
    if (genderAllowance != null) {
      params['genderAllowance'] =
          Property.genderAllowanceToString(genderAllowance!);
    }
    if (services != null && services!.isNotEmpty) {
      params['services'] =
          services!.join(','); // Backend expects comma-separated
    }
    if (rentAgreementAvailable != null) {
      params['rentAgreementAvailable'] = rentAgreementAvailable.toString();
    }
    if (isVerified != null) params['isVerified'] = isVerified.toString();
    if (nearMeLat != null) params['nearMeLat'] = nearMeLat.toString();
    if (nearMeLng != null) params['nearMeLng'] = nearMeLng.toString();
    if (nearMeRadius != null) params['nearMeRadius'] = nearMeRadius.toString();
    if (sortBy != null) params['sortBy'] = sortBy;

    return params;
  }

  // Optional: Add copyWith method for easier state management
  PropertyFilter copyWith({
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
    PropertyType? propertyType, // Use Enum
    GenderAllowance? genderAllowance, // Use Enum
    List<String>? services,
    bool? rentAgreementAvailable,
    bool? isVerified,
    double? nearMeLat,
    double? nearMeLng,
    double? nearMeRadius,
    String? sortBy,
  }) {
    return PropertyFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistance: maxDistance ?? this.maxDistance,
      propertyType: propertyType,
      genderAllowance: genderAllowance ?? this.genderAllowance,
      services: services ?? this.services,
      rentAgreementAvailable:
          rentAgreementAvailable ?? this.rentAgreementAvailable,
      isVerified: isVerified ?? this.isVerified,
      nearMeLat: nearMeLat,
      nearMeLng: nearMeLng,
      nearMeRadius: nearMeRadius ?? this.nearMeRadius,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
