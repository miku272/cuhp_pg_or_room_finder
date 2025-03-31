import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/user.dart';
import '../../data/models/property_form_data.dart';
import '../../domain/usecases/add_property_listing.dart';
import '../../domain/usecases/update_property_listing.dart';

part 'property_listings_event.dart';

part 'property_listings_state.dart';

class PropertyListingsBloc
    extends Bloc<PropertyListingsEvent, PropertyListingsState> {
  final AddPropertyListing _addPropertyListing;
  final UpdatePropertyListing _updatePropertyListing;
  final AppUserCubit _appUserCubit;

  PropertyListingsBloc({
    required AddPropertyListing addPropertyListing,
    required AppUserCubit appUserCubit,
    required UpdatePropertyListing updatePropertyListing,
  })  : _addPropertyListing = addPropertyListing,
        _appUserCubit = appUserCubit,
        _updatePropertyListing = updatePropertyListing,
        super(PropertyListingsInitial()) {
    on<PropertyListingsEvent>((event, emit) => emit(PropertyListingsLoading()));

    on<PropertyListingAddEvent>((event, emit) async {
      final res = await _addPropertyListing(AddPropertyListingParams(
        propertyFormData: event.propertyFormData,
        images: event.images,
        token: event.token,
        userId: event.userId,
        username: event.username,
      ));

      res.fold(
        (failure) => emit(AddPropertyListingsFailure(
          status: failure.status,
          message: failure.message,
        )),
        (property) {
          final userState = _appUserCubit.state;

          if (userState is AppUserLoggedin) {
            final String propertyId = property.id!;

            User updatedUser = userState.user;
            updatedUser.property.add(propertyId);

            _appUserCubit.setUser(updatedUser);
          }

          emit(AddPropertyListingsSuccess(property: property));
        },
      );
    });

    on<PropertyListingUpdateEvent>((event, emit) async {
      final res = await _updatePropertyListing(UpdatePropertyListingParams(
        propertyId: event.propertyId,
        propertyFormData: event.propertyFormData,
        images: event.images,
        imagesToDelete: event.imagesToDelete,
        token: event.token,
        username: event.username,
      ));

      res.fold(
        (failure) => emit(UpdatePropertyListingsFailure(
          status: failure.status,
          message: failure.message,
        )),
        (property) => emit(
          UpdatePropertyListingsSuccess(property: property),
        ),
      );
    });
  }
}
