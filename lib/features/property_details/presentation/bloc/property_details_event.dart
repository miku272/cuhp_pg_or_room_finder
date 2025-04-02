part of 'property_details_bloc.dart';

@immutable
sealed class PropertyDetailsEvent {}

final class GetPropertyDetailsEvent extends PropertyDetailsEvent {
  final String propertyId;
  final String token;

  GetPropertyDetailsEvent({
    required this.propertyId,
    required this.token,
  });
}

final class UpdateProperty extends PropertyDetailsEvent {
  final Property property;

  UpdateProperty({
    required this.property,
  });
}
