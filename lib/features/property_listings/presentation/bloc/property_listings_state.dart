part of 'property_listings_bloc.dart';

@immutable
sealed class PropertyListingsState {}

final class PropertyListingsInitial extends PropertyListingsState {}

final class PropertyListingsLoading extends PropertyListingsState {}

final class AddPropertyListingsSuccess extends PropertyListingsState {
  final Property property;

  AddPropertyListingsSuccess({required this.property});
}

final class AddPropertyListingsFailure extends PropertyListingsState {
  final int? status;
  final String message;

  AddPropertyListingsFailure({this.status, required this.message});
}

final class UpdatePropertyListingsSuccess extends PropertyListingsState {
  final Property property;

  UpdatePropertyListingsSuccess({required this.property});
}

final class UpdatePropertyListingsFailure extends PropertyListingsState {
  final int? status;
  final String message;

  UpdatePropertyListingsFailure({this.status, required this.message});
}