part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeResetEvent extends HomeEvent {
  HomeResetEvent();
}

final class UpdatePropertyFilterEvent extends HomeEvent {
  final PropertyFilter propertyFilter;
  final String token;

  UpdatePropertyFilterEvent({
    required this.propertyFilter,
    required this.token,
  });
}

final class GetPropertiesByPaginationEvent extends HomeEvent {
  final int page;
  final int limit;
  final PropertyFilter filter;
  final String token;

  GetPropertiesByPaginationEvent({
    required this.page,
    required this.limit,
    required this.filter,
    required this.token,
  });
}

final class HomeAddSavedItemEvent extends HomeEvent {
  final String propertyId;
  final String token;

  HomeAddSavedItemEvent({
    required this.propertyId,
    required this.token,
  });
}

final class HomeRemoveSavedItemEvent extends HomeEvent {
  final String propertyId;
  final String token;

  HomeRemoveSavedItemEvent({
    required this.propertyId,
    required this.token,
  });
}
