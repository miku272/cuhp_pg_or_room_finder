import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';

import '../../domain/usecases/initialize_chat.dart';
import '../../domain/usecases/add_property_review.dart';
import '../../domain/usecases/delete_property_review.dart';
import '../../domain/usecases/get_current_user_review.dart';
import '../../domain/usecases/get_property_details.dart';
import '../../domain/usecases/get_recent_property_reviews.dart';
import '../../domain/usecases/update_property_review.dart';

part 'property_details_state.dart';
part 'property_details_event.dart';

class PropertyDetailsBloc
    extends Bloc<PropertyDetailsEvent, PropertyDetailsState> {
  final GetPropertyDetails _getPropertyDetails;
  final AddPropertyReview _addPropertyReview;
  final UpdatePropertyReview _updatePropertyReview;
  final DeletePropertyReview _deletePropertyReview;
  final GetCurrentUserReview _getCurrentUserReview;
  final GetRecentPropertyReviews _getRecentPropertyReviews;
  final InitializeChat _initializeChat;

  PropertyDetailsBloc({
    required GetPropertyDetails getPropertyDetails,
    required AddPropertyReview addPropertyReview,
    required UpdatePropertyReview updatePropertyReview,
    required DeletePropertyReview deletePropertyReview,
    required GetCurrentUserReview getCurrentUserReview,
    required GetRecentPropertyReviews getRecentPropertyReviews,
    required InitializeChat initializeChat,
  })  : _getPropertyDetails = getPropertyDetails,
        _addPropertyReview = addPropertyReview,
        _updatePropertyReview = updatePropertyReview,
        _deletePropertyReview = deletePropertyReview,
        _getCurrentUserReview = getCurrentUserReview,
        _getRecentPropertyReviews = getRecentPropertyReviews,
        _initializeChat = initializeChat,
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
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
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
          totalReviewsCount: state.totalReviewsCount,
          recentReviews: state.recentReviews,
        )),
        (property) {
          emit(PropertyDetailsSuccess(
            property: property,
            currentUserReview: state.currentUserReview,
            totalReviewsCount: state.totalReviewsCount,
            recentReviews: state.recentReviews,
          ));
        },
      );
    });

    on<UpdatePropertyEvent>(
      (event, emit) => emit(PropertyDetailsInitial(
        property: event.property,
        currentUserReview: state.currentUserReview,
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
      )),
    );

    on<AddPropertyReviewEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
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
          totalReviewsCount: state.totalReviewsCount,
          recentReviews: state.recentReviews,
        )),
        (review) {
          emit(PropertyReviewSuccess(
            property: state.property,
            currentUserReview: review,
            totalReviewsCount: state.totalReviewsCount,
            recentReviews: state.recentReviews,
          ));
        },
      );
    });

    on<UpdatePropertyReviewEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
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
          totalReviewsCount: state.totalReviewsCount,
          recentReviews: state.recentReviews,
        )),
        (review) {
          emit(PropertyReviewSuccess(
            property: state.property,
            currentUserReview: review,
            totalReviewsCount: state.totalReviewsCount,
            recentReviews: state.recentReviews,
          ));
        },
      );
    });

    on<DeletePropertyReviewEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
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
          totalReviewsCount: state.totalReviewsCount,
          recentReviews: state.recentReviews,
        )),
        (isDeleted) {
          if (isDeleted) {
            emit(PropertyReviewSuccess(
              property: state.property,
              currentUserReview: null,
              totalReviewsCount: state.totalReviewsCount,
              recentReviews: state.recentReviews,
            ));
          } else {
            emit(PropertyReviewFailure(
              status: null,
              message: 'Failed to delete review',
              property: state.property,
              currentUserReview: state.currentUserReview,
              totalReviewsCount: state.totalReviewsCount,
              recentReviews: state.recentReviews,
            ));
          }
        },
      );
    });

    on<GetPropertyReviewForCurrentUserEvent>((event, emit) async {
      emit(PropertyReviewLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
      ));

      final res = await _getCurrentUserReview(
        GetCurrentUserReviewParams(
          propertyId: event.propertyId,
          userId: event.userId,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertyReviewFailure(
          status: failure.status,
          message: failure.message,
          property: state.property,
          currentUserReview: state.currentUserReview,
          totalReviewsCount: state.totalReviewsCount,
          recentReviews: state.recentReviews,
        )),
        (review) {
          emit(PropertyReviewSuccess(
            property: state.property,
            currentUserReview: review,
            totalReviewsCount: state.totalReviewsCount,
            recentReviews: state.recentReviews,
          ));
        },
      );
    });

    on<GetRecentPropertyReviewsEvent>((event, emit) async {
      emit(PropertyRecentReviewsLoading(
        property: state.property,
        currentUserReview: state.currentUserReview,
        totalReviewsCount: state.totalReviewsCount,
        recentReviews: state.recentReviews,
      ));

      final res = await _getRecentPropertyReviews(
        GetRecentPropertyReviewsParams(
          propertyId: event.propertyId,
          limit: event.limit,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(PropertyRecentReviewsFailure(
          status: failure.status,
          message: failure.message,
          property: state.property,
          currentUserReview: state.currentUserReview,
          recentReviews: state.recentReviews,
          totalReviewsCount: state.totalReviewsCount,
        )),
        (recentReviewsResponse) {
          emit(PropertyRecentReviewsSuccess(
            property: state.property,
            currentUserReview: state.currentUserReview,
            totalReviewsCount: recentReviewsResponse.totalReviews,
            recentReviews: recentReviewsResponse.reviews,
          ));
        },
      );
    });

    on<InitializeChatEvent>((event, emit) async {
      final res = await _initializeChat(
        InitializeChatParams(
          propertyId: event.propertyId,
          token: event.token,
        ),
      );

      res.fold(
        (failure) => emit(
          InitializeChatFailure(
            status: failure.status,
            message: failure.message,
            property: state.property,
            currentUserReview: state.currentUserReview,
            totalReviewsCount: state.totalReviewsCount,
            recentReviews: state.recentReviews,
            chat: state.chat,
          ),
        ),
        (chat) {
          emit(
            InitializeChatSuccess(
              property: state.property,
              currentUserReview: state.currentUserReview,
              totalReviewsCount: state.totalReviewsCount,
              recentReviews: state.recentReviews,
              chat: chat,
            ),
          );
        },
      );
    });
  }
}
