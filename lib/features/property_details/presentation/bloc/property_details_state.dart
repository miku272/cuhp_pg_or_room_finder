part of 'property_details_bloc.dart';

@immutable
sealed class PropertyDetailsState {
  final Property? property;

  const PropertyDetailsState({this.property});
}

final class PropertyDetailsInitial extends PropertyDetailsState {
  const PropertyDetailsInitial({super.property});
}

final class PropertyDetailsLoading extends PropertyDetailsState {
  const PropertyDetailsLoading({super.property});
}

final class PropertyDetailsSuccess extends PropertyDetailsState {
  const PropertyDetailsSuccess({required super.property});
}

final class PropertyDetailsFailure extends PropertyDetailsState {
  final int? status;
  final String message;

  const PropertyDetailsFailure({
    this.status,
    required this.message,
    super.property,
  });
}
