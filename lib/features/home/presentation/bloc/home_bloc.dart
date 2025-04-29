import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/property.dart';
import '../../data/models/property_filter.dart';
import '../../domain/usecases/get_properties_by_pagination.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPropertiesByPagination _getPropertiesByPagination;

  HomeBloc({
    required GetPropertiesByPagination getPropertiesByPagination,
  })  : _getPropertiesByPagination = getPropertiesByPagination,
        super(const HomeInitial(
          properties: [],
          propertyFilter: PropertyFilter(),
          currentPage: 1,
          totalPages: 0,
          hasReachedMax: false,
        )) {
    on<UpdatePropertyFilterEvent>(_onUpdatePropertyFilter);
    on<GetPropertiesByPaginationEvent>(_onGetPropertiesByPagination);
  }

  void _onUpdatePropertyFilter(
    UpdatePropertyFilterEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeInitial(
      properties: const [],
      propertyFilter: event.propertyFilter,
      currentPage: 1,
      totalPages: 0,
      hasReachedMax: false,
    ));

    add(GetPropertiesByPaginationEvent(
      page: 1,
      limit: 10,
      filter: event.propertyFilter,
      token: event.token,
    ));
  }

  void _onGetPropertiesByPagination(
    GetPropertiesByPaginationEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoading || (state.hasReachedMax && event.page > 1)) {
      return;
    }

    emit(HomeLoading(
      properties: state.properties,
      propertyFilter: state.propertyFilter,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      hasReachedMax: state.hasReachedMax,
    ));

    final res = await _getPropertiesByPagination(
      GetPropertiesByPaginationParams(
        page: event.page,
        limit: event.limit,
        filter: event.filter,
        token: event.token,
      ),
    );

    res.fold(
      (failure) => emit(HomeLoadingFailure(
        status: failure.status,
        message: failure.message,
        properties: state.properties,
        propertyFilter: state.propertyFilter,
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        hasReachedMax: state.hasReachedMax,
      )),
      (paginatedResponse) {
        final newProperties = paginatedResponse.data.properties;
        final bool hasReachedMax = paginatedResponse.pagination.currentPage >=
            paginatedResponse.pagination.totalPages;

        final updatedProperties = [...state.properties, ...newProperties];

        emit(HomeLoadingSuccess(
          properties: updatedProperties,
          propertyFilter: event.filter,
          currentPage: paginatedResponse.pagination.currentPage,
          totalPages: paginatedResponse.pagination.totalPages,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }
}
