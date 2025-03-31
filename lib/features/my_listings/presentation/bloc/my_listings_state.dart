part of 'my_listings_bloc.dart';

@immutable
sealed class MyListingsState {
  final List<Property> properties;

  const MyListingsState({
    this.properties = const [],
  });
}

final class MyListingsInitial extends MyListingsState {
  const MyListingsInitial() : super(properties: const []);
}

final class MyListingsLoading extends MyListingsState {
  const MyListingsLoading({required super.properties});
}

final class PropertyLoading extends MyListingsState {
  final String propertyId;

  const PropertyLoading({
    required super.properties,
    required this.propertyId,
  });
}

final class MyListingsSuccess extends MyListingsState {
  const MyListingsSuccess({required super.properties});
}

final class PropertySuccess extends MyListingsState {
  const PropertySuccess({required super.properties});
}

final class MyListingsFailure extends MyListingsState {
  final int? status;
  final String message;

  const MyListingsFailure({
    this.status,
    required this.message,
    required super.properties,
  });
}

final class PropertyFailure extends MyListingsState {
  final int? status;
  final String message;

  const PropertyFailure({
    this.status,
    required this.message,
    required super.properties,
  });
}
