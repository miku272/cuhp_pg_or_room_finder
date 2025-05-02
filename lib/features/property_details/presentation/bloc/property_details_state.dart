part of 'property_details_bloc.dart';

@immutable
sealed class PropertyDetailsState {
  final Property? property;
  final Review? currentUserReview;
  final int totalReviewsCount;
  final List<Review> recentReviews;
  final Chat? chat;

  const PropertyDetailsState({
    this.property,
    this.currentUserReview,
    this.totalReviewsCount = 0,
    this.recentReviews = const [],
    this.chat,
  });
}

final class PropertyDetailsInitial extends PropertyDetailsState {
  const PropertyDetailsInitial({
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyDetailsLoading extends PropertyDetailsState {
  const PropertyDetailsLoading({
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyReviewLoading extends PropertyDetailsState {
  const PropertyReviewLoading({
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyRecentReviewsLoading extends PropertyDetailsState {
  const PropertyRecentReviewsLoading({
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class InitializeChatLoading extends PropertyDetailsState {
  const InitializeChatLoading({
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyDetailsSuccess extends PropertyDetailsState {
  const PropertyDetailsSuccess({
    required super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyReviewSuccess extends PropertyDetailsState {
  const PropertyReviewSuccess({
    required super.currentUserReview,
    super.property,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyRecentReviewsSuccess extends PropertyDetailsState {
  const PropertyRecentReviewsSuccess({
    required super.recentReviews,
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.chat,
  });
}

final class InitializeChatSuccess extends PropertyDetailsState {
  const InitializeChatSuccess({
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    required super.chat,
  });
}

final class PropertyDetailsFailure extends PropertyDetailsState {
  final int? status;
  final String message;

  const PropertyDetailsFailure({
    this.status,
    required this.message,
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyReviewFailure extends PropertyDetailsState {
  final int? status;
  final String message;

  const PropertyReviewFailure({
    this.status,
    required this.message,
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class PropertyRecentReviewsFailure extends PropertyDetailsState {
  final int? status;
  final String message;

  const PropertyRecentReviewsFailure({
    this.status,
    required this.message,
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}

final class InitializeChatFailure extends PropertyDetailsState {
  final int? status;
  final String message;

  const InitializeChatFailure({
    this.status,
    required this.message,
    super.property,
    super.currentUserReview,
    super.totalReviewsCount,
    super.recentReviews,
    super.chat,
  });
}
