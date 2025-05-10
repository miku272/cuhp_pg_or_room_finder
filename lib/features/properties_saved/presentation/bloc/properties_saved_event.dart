part of 'properties_saved_bloc.dart';

@immutable
sealed class PropertiesSavedEvent {}

final class PropertiesSavedResetEvent extends PropertiesSavedEvent {}

final class AddSavedItemEvent extends PropertiesSavedEvent {
  final String propertyId;
  final String token;

  AddSavedItemEvent({
    required this.propertyId,
    required this.token,
  });
}

final class RemoveSavedItemEvent extends PropertiesSavedEvent {
  final String savedItemId;
  final String token;

  RemoveSavedItemEvent({
    required this.savedItemId,
    required this.token,
  });
}

final class GetSavedItemsEvent extends PropertiesSavedEvent {
  final int page;
  final int limit;
  final String token;

  GetSavedItemsEvent({
    required this.page,
    required this.limit,
    required this.token,
  });
}
