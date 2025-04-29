part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

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
