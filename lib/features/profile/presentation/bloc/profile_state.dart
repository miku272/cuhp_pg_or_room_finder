part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {
  final User? user;
  final int? totalCount;
  final int? activeCount;
  final int? inactiveCount;
  final int? totalReviews;
  final double? overallAverageRating;

  const ProfileState({
    this.user,
    this.totalCount,
    this.activeCount,
    this.inactiveCount,
    this.totalReviews,
    this.overallAverageRating,
  });
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial({
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading({
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class PropertyMetadataLoading extends ProfileState {
  const PropertyMetadataLoading({
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

class UserReviewMetadataLoading extends ProfileState {
  const UserReviewMetadataLoading({
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class TotalPropertyCountSuccess extends ProfileState {
  const TotalPropertyCountSuccess({
    required super.totalCount,
    super.user,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class PropertiesActiveAndInactiveCountSuccess extends ProfileState {
  const PropertiesActiveAndInactiveCountSuccess({
    required super.activeCount,
    required super.inactiveCount,
    super.user,
    super.totalCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess({
    required super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class UserReviewMetadataSuccess extends ProfileState {
  const UserReviewMetadataSuccess({
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    required super.totalReviews,
    required super.overallAverageRating,
  });
}

final class PropertyMetadataFailure extends ProfileState {
  final int? status;
  final String message;

  const PropertyMetadataFailure({
    this.status,
    required this.message,
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class ProfileFailure extends ProfileState {
  final int? status;
  final String message;

  const ProfileFailure({
    this.status,
    required this.message,
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}

final class UserReviewMetadataFailure extends ProfileState {
  final int? status;
  final String message;

  const UserReviewMetadataFailure({
    this.status,
    required this.message,
    super.user,
    super.totalCount,
    super.activeCount,
    super.inactiveCount,
    super.totalReviews,
    super.overallAverageRating,
  });
}
