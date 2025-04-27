import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failures.dart';

import '../../domain/repository/property_details_repository.dart';
import '../datasources/property_details_remote_datasource.dart';

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
  Future<Either<Failure, bool>> deletePropertyReview(
      {required String reviewId, required String token}) {
    // TODO: implement deletePropertyReview
    throw UnimplementedError();
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
}
