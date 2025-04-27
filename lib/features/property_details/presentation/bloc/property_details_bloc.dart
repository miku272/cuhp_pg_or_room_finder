import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';

import '../../domain/usecases/add_property_review.dart';
import '../../domain/usecases/delete_property_review.dart';
import '../../domain/usecases/get_property_details.dart';
import '../../domain/usecases/update_property_review.dart';

part 'property_details_event.dart';

part 'property_details_state.dart';

class PropertyDetailsBloc
    extends Bloc<PropertyDetailsEvent, PropertyDetailsState> {
  final GetPropertyDetails _getPropertyDetails;
  final AddPropertyReview _addPropertyReview;
  final UpdatePropertyReview _updatePropertyReview;
  final DeletePropertyReview _deletePropertyReview;

  PropertyDetailsBloc({
    required GetPropertyDetails getPropertyDetails,
    required AddPropertyReview addPropertyReview,
    required UpdatePropertyReview updatePropertyReview,
    required DeletePropertyReview deletePropertyReview,
  })  : _getPropertyDetails = getPropertyDetails,
        _addPropertyReview = addPropertyReview,
        _updatePropertyReview = updatePropertyReview,
        _deletePropertyReview = deletePropertyReview,
        super(const PropertyDetailsInitial()) {
    // on<PropertyDetailsEvent>(
    //   (event, emit) => emit(PropertyDetailsLoading(
    //     property: state.property,
    //     currentUserReview: state.currentUserReview,
    //   )),
    // );

    on<GetPropertyDetailsEvent>((event, emit) async {
      emit(PropertyDetailsLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
      ));

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
          property: state.property,
          currentUserReview: state.currentUserReview,
        )),
        (property) {
          emit(PropertyDetailsSuccess(
            property: property,
            currentUserReview: state.currentUserReview,
          ));
        },
      );
    });

    on<UpdatePropertyEvent>(
      (event, emit) => emit(PropertyDetailsInitial(
        property: event.property,
        currentUserReview: state.currentUserReview,
      )),
    );

    on<AddPropertyReviewEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
      ));

      final res = await _addPropertyReview(
        AddPropertyReviewParams(
          propertyId: event.propertyId,
          rating: event.rating,
          review: event.review,
          isAnonymous: event.isAnonymous,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertyReviewFailure(
          status: failure.status,
          message: failure.message,
          property: state.property,
          currentUserReview: state.currentUserReview,
        )),
        (review) {
          emit(PropertyReviewSuccess(
            property: state.property,
            currentUserReview: review,
          ));
        },
      );
    });

    on<UpdatePropertyReviewEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
      ));

      final res = await _updatePropertyReview(
        UpdatePropertyReviewParams(
          reviewId: event.reviewId,
          rating: event.rating,
          review: event.review,
          isAnonymous: event.isAnonymous,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertyReviewFailure(
          status: failure.status,
          message: failure.message,
          property: state.property,
          currentUserReview: state.currentUserReview,
        )),
        (review) {
          emit(PropertyReviewSuccess(
            property: state.property,
            currentUserReview: review,
          ));
        },
      );
    });

    on<DeletePropertyReviewEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
      ));

      final res = await _deletePropertyReview(DeletePropertyReviewParams(
        reviewId: event.reviewId,
        token: event.token,
      ));

      res.fold(
        (failure) => emit(PropertyReviewFailure(
          status: failure.status,
          message: failure.message,
          property: state.property,
          currentUserReview: state.currentUserReview,
        )),
        (isDeleted) {
          if (isDeleted) {
            emit(PropertyReviewSuccess(
              property: state.property,
              currentUserReview: null,
            ));
          } else {
            emit(PropertyReviewFailure(
              status: null,
              message: 'Failed to delete review',
              property: state.property,
              currentUserReview: state.currentUserReview,
            ));
          }
        },
      );
    });
  }
}
