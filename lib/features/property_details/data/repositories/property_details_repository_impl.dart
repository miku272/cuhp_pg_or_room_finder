import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../../domain/repository/property_details_repository.dart';
import '../datasources/property_details_remote_datasource.dart';
import '../models/recent_property_reviews_response.dart';

class PropertyDetailsRepositoryImpl implements PropertyDetailsRepository {
  final PropertyDetailsRemoteDatasource propertyDetailsRemoteDatasource;

  const PropertyDetailsRepositoryImpl({
    required this.propertyDetailsRemoteDatasource,
  });

  @override
  Future<Either<Failure, Property>> getPropertyDetails({
    required String propertyId,
    required String token,
  }) async {
    try {
      final property = await propertyDetailsRemoteDatasource.getPropertyDetails(
        propertyId,
        token,
      );

      return right(property);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> addPropertyReview({
    required String propertyId,
    required int rating,
    String? review,
    required bool isAnonymous,
    required String token,
  }) async {
    try {
      final reviewResponse =
          await propertyDetailsRemoteDatasource.addPropertyReview(
        propertyId,
        rating,
        review,
        isAnonymous,
        token,
      );

      return right(reviewResponse);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePropertyReview({
    required String reviewId,
    required String token,
  }) async {
    try {
      final isDeleted =
          await propertyDetailsRemoteDatasource.deletePropertyReview(
        reviewId,
        token,
      );

      return right(isDeleted);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> updatePropertyReview({
    required String reviewId,
    required int rating,
    required String? review,
    required bool isAnonymous,
    required String token,
  }) async {
    try {
      final updatedReviewResponse =
          await propertyDetailsRemoteDatasource.updatePropertyReview(
        reviewId,
        rating,
        review,
        isAnonymous,
        token,
      );

      return right(updatedReviewResponse);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> getCurrentUserReview({
    required String propertyId,
    required String userId,
    required String token,
  }) async {
    try {
      final review = await propertyDetailsRemoteDatasource.getCurrentUserReview(
        propertyId,
        userId,
        token,
      );

      return right(review);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, RecentPropertyReviewsResponse>>
      getRecentPropertyReviews({
    required String propertyId,
    required int limit,
    required String token,
  }) async {
    try {
      final recentPropertyReviewsResponse =
          await propertyDetailsRemoteDatasource.getRecentPropertyReviews(
        propertyId,
        limit,
        token,
      );

      return right(recentPropertyReviewsResponse);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Chat>> initializeChat({
    required String propertyId,
    required String token,
  }) async {
    try {
      final chat = await propertyDetailsRemoteDatasource.initializeChat(
        propertyId,
        token,
      );

      return right(chat);
    } on ServerException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } on UserException catch (error) {
      return left(Failure(status: error.status, message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
