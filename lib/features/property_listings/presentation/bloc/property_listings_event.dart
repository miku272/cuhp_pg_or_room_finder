part of 'property_listings_bloc.dart';

@immutable
sealed class PropertyListingsEvent {}

final class PropertyListingsResetEvent extends PropertyListingsEvent {}

final class PropertyListingAddEvent extends PropertyListingsEvent {
  final PropertyFormData propertyFormData;
  final List<File> images;
  final String token;
  final String userId;
  final String username;

  PropertyListingAddEvent({
    required this.propertyFormData,
    required this.images,
    required this.token,
    required this.userId,
    required this.username,
  });
}

final class PropertyListingUpdateEvent extends PropertyListingsEvent {
  final String propertyId;
  final PropertyFormData propertyFormData;
  final List<File> images;
  final List<String> imagesToDelete;
  final String token;
  final String username;

  PropertyListingUpdateEvent({
    required this.propertyId,
    required this.propertyFormData,
    required this.images,
    required this.imagesToDelete,
    required this.token,
    required this.username,
  });
}
