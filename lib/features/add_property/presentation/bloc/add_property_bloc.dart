import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_property_event.dart';
part 'add_property_state.dart';

class AddPropertyBloc extends Bloc<AddPropertyEvent, AddPropertyState> {
  AddPropertyBloc() : super(AddPropertyInitial()) {
    on<AddPropertyEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
