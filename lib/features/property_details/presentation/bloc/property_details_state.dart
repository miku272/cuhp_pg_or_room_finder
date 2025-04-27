part of 'property_details_bloc.dart';

@immutable
sealed class PropertyDetailsState {
  final Property? property;
  final Review? currentUserReview;

  const PropertyDetailsState({this.property, this.currentUserReview});
}

final class PropertyDetailsInitial extends PropertyDetailsState {
  const PropertyDetailsInitial({super.property, super.currentUserReview});
}

final class PropertyDetailsLoading extends PropertyDetailsState {
  const PropertyDetailsLoading({super.property, super.currentUserReview});
}

final class PropertyReviewLoading extends PropertyDetailsState {
  const PropertyReviewLoading({super.property, super.currentUserReview});
}

final class PropertyDetailsSuccess extends PropertyDetailsState {
  const PropertyDetailsSuccess({
    required super.property,
    super.currentUserReview,
  });
}

final class PropertyReviewSuccess extends PropertyDetailsState {
  const PropertyReviewSuccess({
    required super.currentUserReview,
    super.property,
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
  });
}
