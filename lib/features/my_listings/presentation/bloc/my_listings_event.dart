part of 'my_listings_bloc.dart';

@immutable
sealed class MyListingsEvent {}

final class MyListingsResetEvent extends MyListingsEvent {}

final class GetPropertiesByIdEvent extends MyListingsEvent {
  final List<String> propertyIds;
  final String token;

  GetPropertiesByIdEvent({
    required this.propertyIds,
    required this.token,
  });
}

final class TogglePropertyActivationEvent extends MyListingsEvent {
  final String propertyId;
  final String token;

  TogglePropertyActivationEvent({
    required this.propertyId,
    required this.token,
  });
}

final class MyListingsReset extends MyListingsEvent {}
