import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'property_details_event.dart';

part 'property_details_state.dart';

class PropertyDetailsBloc
    extends Bloc<PropertyDetailsEvent, PropertyDetailsState> {
  PropertyDetailsBloc() : super(PropertyDetailsInitial()) {
    on<PropertyDetailsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
