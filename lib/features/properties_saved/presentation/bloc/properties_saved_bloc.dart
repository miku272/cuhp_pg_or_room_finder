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
        super(const PropertiesSavedInitial()) {
    on<PropertiesSavedResetEvent>((event, emit) {
      emit(const PropertiesSavedInitial());
    });

    on<AddSavedItemEvent>((event, emit) async {
      emit(PropertiesSavedLoading(
        savedItems: state.savedItems,
        currentPage: state.currentPage,
        currentLimit: state.currentLimit,
        totalPages: state.totalPages,
        totalSavedInDatabase: state.totalSavedInDatabase,
        hasReachedMax: state.hasReachedMax,
      ));

      final res = await _addSavedItem(
        AddSavedItemParams(
          propertyId: event.propertyId,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertiesSavedFailure(
          status: failure.status,
          message: failure.message,
          savedItems: state.savedItems,
          currentPage: state.currentPage,
          currentLimit: state.currentLimit,
          totalPages: state.totalPages,
          totalSavedInDatabase: state.totalSavedInDatabase,
          hasReachedMax: state.hasReachedMax,
        )),
        (savedItem) {
          final updatedSavedItems = [...state.savedItems, savedItem];

          emit(AddSavedItemSuccess(
            savedItems: updatedSavedItems,
            currentPage: state.currentPage,
            currentLimit: state.currentLimit,
            totalPages: state.totalPages,
            totalSavedInDatabase: state.totalSavedInDatabase,
            hasReachedMax: state.hasReachedMax,
          ));
        },
      );
    });

    on<RemoveSavedItemEvent>((event, emit) async {
      emit(PropertiesSavedLoading(
        savedItems: state.savedItems,
        currentPage: state.currentPage,
        currentLimit: state.currentLimit,
        totalPages: state.totalPages,
        totalSavedInDatabase: state.totalSavedInDatabase,
        hasReachedMax: state.hasReachedMax,
      ));

      final res = await _removeSavedItem(
        RemoveSavedItemParams(
          savedItemId: event.savedItemId,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertiesSavedFailure(
          status: failure.status,
          message: failure.message,
          savedItems: state.savedItems,
          currentPage: state.currentPage,
          currentLimit: state.currentLimit,
          totalPages: state.totalPages,
          totalSavedInDatabase: state.totalSavedInDatabase,
          hasReachedMax: state.hasReachedMax,
        )),
        (isRemoved) {
          if (isRemoved) {
            final updatedSavedItems = state.savedItems
                .where((savedItem) => savedItem.id != event.savedItemId)
                .toList();

            emit(RemoveSavedItemSuccess(
              savedItems: updatedSavedItems,
              currentPage: state.currentPage,
              currentLimit: state.currentLimit,
              totalPages: state.totalPages,
              totalSavedInDatabase: state.totalSavedInDatabase,
              hasReachedMax: state.hasReachedMax,
            ));
          } else {
            emit(PropertiesSavedFailure(
              status: 500,
              message: 'Failed to remove saved item',
              savedItems: state.savedItems,
              currentPage: state.currentPage,
              currentLimit: state.currentLimit,
              totalPages: state.totalPages,
              totalSavedInDatabase: state.totalSavedInDatabase,
              hasReachedMax: state.hasReachedMax,
            ));
          }
        },
      );
    });

    on<GetSavedItemsEvent>((event, emit) async {
      emit(GetPropertiesSavedLoading(
        savedItems: state.savedItems,
        currentPage: state.currentPage,
        currentLimit: state.currentLimit,
        totalPages: state.totalPages,
        totalSavedInDatabase: state.totalSavedInDatabase,
        hasReachedMax: state.hasReachedMax,
      ));

      final res = await _getSavedItems(
        GetSavedItemsParams(
          page: event.page,
          limit: event.limit,
          token: event.token,
        ),
      );

      res.fold(
        (failure) {
          emit(GetPropertiesSavedFailure(
            status: failure.status,
            message: failure.message,
            savedItems: state.savedItems,
            currentPage: state.currentPage,
            currentLimit: state.currentLimit,
            totalPages: state.totalPages,
            totalSavedInDatabase: state.totalSavedInDatabase,
            hasReachedMax: state.hasReachedMax,
          ));
        },
        (getSavedItemResponse) {
          final bool hasReachedMax =
              getSavedItemResponse.paginationData.currentPage >=
                  getSavedItemResponse.paginationData.totalPages;

          emit(GetPropertiesSavedSuccess(
            savedItems: [
              ...state.savedItems,
              ...getSavedItemResponse.savedItems
            ],
            currentPage: getSavedItemResponse.paginationData.currentPage,
            currentLimit: getSavedItemResponse.paginationData.limit,
            totalPages: getSavedItemResponse.paginationData.totalPages,
            totalSavedInDatabase:
                getSavedItemResponse.paginationData.totalSaved,
            hasReachedMax: hasReachedMax,
          ));
        },
      );
    });
  }
}
