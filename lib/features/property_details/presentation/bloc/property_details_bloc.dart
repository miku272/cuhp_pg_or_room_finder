import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/property.dart';
import '../../domain/usecases/get_property_details.dart';

part 'property_details_event.dart';

part 'property_details_state.dart';

class PropertyDetailsBloc
    extends Bloc<PropertyDetailsEvent, PropertyDetailsState> {
  final GetPropertyDetails _getPropertyDetails;

  PropertyDetailsBloc({required GetPropertyDetails getPropertyDetails})
      : _getPropertyDetails = getPropertyDetails,
        super(const PropertyDetailsInitial()) {
    on<PropertyDetailsEvent>(
      (event, emit) => emit(PropertyDetailsLoading(property: state.property)),
    );

    on<GetPropertyDetailsEvent>((event, emit) async {
      final res = await _getPropertyDetails(
        GetPropertyDetailsParams(
          propertyId: event.propertyId,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertyDetailsFailure(
          status: failure.status,
          message: failure.message,
        )),
        (property) {
          emit(PropertyDetailsSuccess(property: property));
        },
      );
    });

    on<UpdateProperty>(
      (event, emit) => emit(PropertyDetailsInitial(property: event.property)),
    );
  }
}
