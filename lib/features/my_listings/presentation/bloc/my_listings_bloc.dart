import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/property.dart';
import '../../domain/usecases/get_properties_by_id.dart';
import '../../domain/usecases/toggle_property_activation.dart';

part 'my_listings_event.dart';

part 'my_listings_state.dart';

class MyListingsBloc extends Bloc<MyListingsEvent, MyListingsState> {
  final GetPropertiesById _getPropertiesById;
  final TogglePropertyActivation _togglePropertyActivation;

  MyListingsBloc({
    required GetPropertiesById getPropertiesById,
    required TogglePropertyActivation togglePropertyActivation,
  })  : _getPropertiesById = getPropertiesById,
        _togglePropertyActivation = togglePropertyActivation,
        super(const MyListingsInitial()) {
    on<GetPropertiesByIdEvent>((event, emit) async {
      emit(MyListingsLoading(properties: state.properties));

      final res = await _getPropertiesById(
        GetPropertiesByIdParams(
          propertyIds: event.propertyIds,
          token: event.token,
        ),
      );

      res.fold(
        (failure) {
          emit(MyListingsFailure(
            status: failure.status,
            message: failure.message,
            properties: state.properties,
          ));
        },
        (List<Property> properties) {
          final updatedProperties = [...state.properties, ...properties];

          emit(MyListingsSuccess(properties: updatedProperties));
        },
      );
    });

    on<TogglePropertyActivationEvent>((event, emit) async {
      emit(PropertyLoading(
        properties: state.properties,
        propertyId: event.propertyId,
      ));

      final res = await _togglePropertyActivation(
        TogglePropertyActivationParams(
          propertyId: event.propertyId,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(
          PropertyFailure(
            status: failure.status,
            message: failure.message,
            properties: state.properties,
          ),
        ),
        (property) {
          final updatedProperties = state.properties.map((prop) {
            return prop.id == property.id ? property : prop;
          }).toList();

          emit(PropertySuccess(properties: updatedProperties));
        },
      );
    });

    on<MyListingsReset>(
      (event, emit) => emit(const MyListingsSuccess(properties: [])),
    );
  }
}
