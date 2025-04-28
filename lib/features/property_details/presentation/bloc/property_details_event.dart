part of 'property_details_bloc.dart';

@immutable
sealed class PropertyDetailsEvent {}

final class GetPropertyDetailsEvent extends PropertyDetailsEvent {
  final String propertyId;
  final String token;

  GetPropertyDetailsEvent({
    required this.propertyId,
    required this.token,
  });
}

final class UpdatePropertyEvent extends PropertyDetailsEvent {
  final Property property;

  UpdatePropertyEvent({
    required this.property,
  });
}

final class GetPropertyReviewForCurrentUserEvent extends PropertyDetailsEvent {
  final String propertyId;
  final String token;

  GetPropertyReviewForCurrentUserEvent({
    required this.propertyId,
    required this.token,
  });
}

final class AddPropertyReviewEvent extends PropertyDetailsEvent {
  final String propertyId;
  final int rating;
  final String? review;
  final bool isAnonymous;
  final String token;

  AddPropertyReviewEvent({
    required this.propertyId,
    required this.rating,
    this.review,
    required this.isAnonymous,
    required this.token,
  });
}

final class UpdatePropertyReviewEvent extends PropertyDetailsEvent {
  final String reviewId;
  final int rating;
  final String? review;
  final bool isAnonymous;
  final String token;

  UpdatePropertyReviewEvent({
    required this.reviewId,
    required this.rating,
    this.review,
    required this.isAnonymous,
    required this.token,
  });
}

final class DeletePropertyReviewEvent extends PropertyDetailsEvent {
  final String reviewId;
  final String token;

  DeletePropertyReviewEvent({
    required this.reviewId,
    required this.token,
  });
}
