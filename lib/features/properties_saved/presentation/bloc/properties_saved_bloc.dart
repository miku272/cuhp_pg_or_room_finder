import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/saved_item.dart';
import '../../domain/usecases/add_saved_item.dart';
import '../../domain/usecases/get_saved_items.dart';
import '../../domain/usecases/remove_saved_item.dart';

part 'properties_saved_event.dart';
part 'properties_saved_state.dart';

class PropertiesSavedBloc
    extends Bloc<PropertiesSavedEvent, PropertiesSavedState> {
  final AddSavedItem _addSavedItem;
  final RemoveSavedItem _removeSavedItem;
  final GetSavedItems _getSavedItems;

  PropertiesSavedBloc({
    required AddSavedItem addSavedItem,
    required RemoveSavedItem removeSavedItem,
    required GetSavedItems getSavedItems,
  })  : _addSavedItem = addSavedItem,
        _removeSavedItem = removeSavedItem,
        _getSavedItems = getSavedItems,
        super(PropertiesSavedInitial()) {
    on<PropertiesSavedEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
