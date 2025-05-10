part of 'home_bloc.dart';

@immutable
sealed class HomeState {
  final List<Property> properties;
  final PropertyFilter propertyFilter;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const HomeState({
    this.properties = const [],
    this.propertyFilter = const PropertyFilter(),
    this.currentPage = 1,
    this.totalPages = 0,
    this.hasReachedMax = false,
  });
}

final class HomeInitial extends HomeState {
  const HomeInitial({
    super.properties = const [],
    super.propertyFilter = const PropertyFilter(),
    super.currentPage = 1,
    super.totalPages = 0,
    super.hasReachedMax = false,
  });
}

final class HomeLoading extends HomeState {
  const HomeLoading({
    super.properties,
    super.propertyFilter,
    super.currentPage,
    super.totalPages,
    super.hasReachedMax,
  });
}

final class HomeSavedItemLoading extends HomeState {
  const HomeSavedItemLoading({
    super.properties,
    super.propertyFilter,
    super.currentPage,
    super.totalPages,
    super.hasReachedMax,
  });
}

final class HomeLoadingSuccess extends HomeState {
  const HomeLoadingSuccess({
    required super.properties,
    super.propertyFilter,
    required super.currentPage,
    super.totalPages,
    super.hasReachedMax,
  });
}

final class HomeSavedItemSuccess extends HomeState {
  final String propertyId;

  const HomeSavedItemSuccess({
    required this.propertyId,
    super.properties,
    super.propertyFilter,
    super.currentPage,
    super.totalPages,
    super.hasReachedMax,
  });
}

final class HomeLoadingFailure extends HomeState {
  final int? status;
  final String message;

  const HomeLoadingFailure({
    this.status,
    required this.message,
    super.properties,
    super.propertyFilter,
    super.currentPage,
    super.totalPages,
    super.hasReachedMax,
  });
}

final class SavedItemFailure extends HomeState {
  final int? status;
  final String message;
  final String propertyId;

  const SavedItemFailure({
    this.status,
    required this.message,
    required this.propertyId,
    super.properties,
    super.propertyFilter,
    super.currentPage,
    super.totalPages,
    super.hasReachedMax,
  });
}
