import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'property_listings_event.dart';
part 'property_listings_state.dart';

class PropertyListingsBloc extends Bloc<PropertyListingsEvent, PropertyListingsState> {
  PropertyListingsBloc() : super(PropertyListingsInitial()) {
    on<PropertyListingsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
