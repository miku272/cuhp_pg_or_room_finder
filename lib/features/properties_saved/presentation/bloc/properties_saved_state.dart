part of 'properties_saved_bloc.dart';

@immutable
sealed class PropertiesSavedState {
  final int totalPages;
  final int currentPage;
  final int currentLimit;
  final bool hasReachedMax;
  final int totalSavedInDatabase;
  final List<SavedItem> savedItems;

  const PropertiesSavedState({
    this.totalPages = 0,
    this.currentPage = 0,
    this.currentLimit = 10,
    this.hasReachedMax = false,
    this.totalSavedInDatabase = 0,
    this.savedItems = const [],
  });
}

final class PropertiesSavedInitial extends PropertiesSavedState {
  const PropertiesSavedInitial({
    super.totalPages = 0,
    super.currentPage = 0,
    super.hasReachedMax = false,
    super.totalSavedInDatabase = 0,
    super.savedItems = const [],
  });
}

final class PropertiesSavedLoading extends PropertiesSavedState {
  const PropertiesSavedLoading({
    super.totalPages,
    super.currentPage,
    super.currentLimit,
    super.hasReachedMax,
    super.totalSavedInDatabase,
    super.savedItems,
  });
}

final class GetPropertiesSavedLoading extends PropertiesSavedState {
  const GetPropertiesSavedLoading({
    super.totalPages,
    super.currentPage,
    super.currentLimit,
    super.hasReachedMax,
    super.totalSavedInDatabase,
    super.savedItems,
  });
}

final class AddSavedItemSuccess extends PropertiesSavedState {
  const AddSavedItemSuccess({
    super.totalPages,
    super.currentPage,
    super.currentLimit,
    super.hasReachedMax,
    super.totalSavedInDatabase,
    required super.savedItems,
  });
}

final class GetPropertiesSavedSuccess extends PropertiesSavedState {
  const GetPropertiesSavedSuccess({
    required super.totalPages,
    required super.currentPage,
    required super.currentLimit,
    required super.hasReachedMax,
    required super.totalSavedInDatabase,
    required super.savedItems,
  });
}

final class RemoveSavedItemSuccess extends PropertiesSavedState {
  const RemoveSavedItemSuccess({
    super.totalPages,
    super.currentPage,
    super.currentLimit,
    super.hasReachedMax,
    super.totalSavedInDatabase,
    required super.savedItems,
  });
}

final class PropertiesSavedFailure extends PropertiesSavedState {
  final int? status;
  final String message;

  const PropertiesSavedFailure({
    this.status,
    required this.message,
    super.totalPages,
    super.currentPage,
    super.currentLimit,
    super.hasReachedMax,
    super.totalSavedInDatabase,
    super.savedItems,
  });
}

final class GetPropertiesSavedFailure extends PropertiesSavedState {
  final int? status;
  final String message;

  const GetPropertiesSavedFailure({
    this.status,
    required this.message,
    super.totalPages,
    super.currentPage,
    super.currentLimit,
    super.hasReachedMax,
    super.totalSavedInDatabase,
    super.savedItems,
  });
}
