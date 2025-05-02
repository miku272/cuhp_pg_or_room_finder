import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/common/entities/coordinate.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/entities/review.dart';
import '../../../../core/error/exception.dart';
import '../models/recent_property_reviews_response.dart';

abstract interface class PropertyDetailsRemoteDatasource {
  Future<Property> getPropertyDetails(String propertyId, String token);
  Future<Review> addPropertyReview(
    String propertyId,
    int rating,
    String? review,
    bool isAnonymous,
    String token,
  );

  Future<Review> updatePropertyReview(
    String reviewId,
    int rating,
    String? review,
    bool isAnonymous,
    String token,
  );

  Future<bool> deletePropertyReview(
    String reviewId,
    String token,
  );

  Future<Review> getCurrentUserReview(
    String propertyId,
    String userId,
    String token,
  );

  Future<RecentPropertyReviewsResponse> getRecentPropertyReviews(
    String propertyId,
    int limit,
    String token,
  );

  Future<Chat> initializeChat(String propertyId, String token);
}

class PropertyDetailsRemoteDataSourceImpl
    implements PropertyDetailsRemoteDatasource {
  final Dio dio;

  PropertyDetailsRemoteDataSourceImpl({required this.dio});

  @override
  Future<Property> getPropertyDetails(String propertyId, String token) async {
    if (token.isEmpty) {
      throw UserException(
        status: 401,
        message: 'Unauthorized',
      );
    }

    try {
      final res = await dio.get(
        '/property/$propertyId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final property = Property(
        id: decodedBody['data']['property']['_id'],
        ownerId: decodedBody['data']['property']['owner'],
        propertyName: decodedBody['data']['property']['propertyName'],
        propertyAddressLine1: decodedBody['data']['property']
            ['propertyAddressLine1'],
        propertyAddressLine2: decodedBody['data']['property']
            ['propertyAddressLine2'],
        propertyVillageOrCity: decodedBody['data']['property']
            ['propertyVillageOrCity'],
        propertyPincode: decodedBody['data']['property']['propertyPincode'],
        ownerName: decodedBody['data']['property']['ownerName'],
        ownerPhone: decodedBody['data']['property']['ownerPhone'],
        ownerEmail: decodedBody['data']['property']['ownerEmail'],
        pricePerMonth: decodedBody['data']['property']['pricePerMonth'],
        propertyType: Property.propertyTypeFromString(
          decodedBody['data']['property']['propertyType'],
        ),
        propertyGenderAllowance: Property.genderAllowanceFromString(
          decodedBody['data']['property']['propertyGenderAllowance'],
        ),
        rentAgreementAvailable: decodedBody['data']['property']
            ['rentAgreementAvailable'],
        coordinates: Coordinate(
          coordinates: decodedBody['data']['property']['coordinates']
              ['coordinates'],
        ),
        distanceFromUniversity: decodedBody['data']['property']
            ['distanceFromUniversity'],
        services:
            Map<String, bool>.from(decodedBody['data']['property']['services']),
        images: List<String>.from(decodedBody['data']['property']['images']),
        isVerified: decodedBody['data']['property']['isVerified'],
        isActive: decodedBody['data']['property']['isActive'],
        numberOfReviews: decodedBody['data']['property']['numberOfReviews'],
        averageRating: (decodedBody['data']['property']['averageRating'] as num)
            .toDouble(),
        createdAt: DateTime.parse(decodedBody['data']['property']['createdAt']),
        updatedAt: DateTime.parse(decodedBody['data']['property']['updatedAt']),
      );

      return property;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Review> addPropertyReview(
    String propertyId,
    int rating,
    String? review,
    bool isAnonymous,
    String token,
  ) async {
    try {
      final res = await dio.post(
        '/review/add-review',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
        data: {
          'property': propertyId,
          'rating': rating,
          'review': review,
          'isAnonymous': isAnonymous,
        },
      );

      final decodedBody = res.data;

      final reviewData = Review.fromJson(decodedBody['data']['review']);

      return reviewData;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> deletePropertyReview(
    String reviewId,
    String token,
  ) async {
    try {
      final res = await dio.delete(
        '/review/$reviewId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      if (res.statusCode == 204 || res.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
          status: res.statusCode,
          message: 'Failed to delete review',
        );
      }
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Review> updatePropertyReview(
    String reviewId,
    int rating,
    String? review,
    bool isAnonymous,
    String token,
  ) async {
    try {
      final res = await dio.patch(
        '/review/$reviewId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
        data: {
          'rating': rating,
          'review': review,
          'isAnonymous': isAnonymous,
        },
      );

      final decodedBody = res.data;

      final reviewData = Review.fromJson(decodedBody['data']['review']);

      return reviewData;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Review> getCurrentUserReview(
    String propertyId,
    String userId,
    String token,
  ) async {
    try {
      final res = await dio.get(
        '/review/property/$propertyId/user/$userId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      final decodedBody = res.data;

      final reviewData = Review.fromJson(decodedBody['data']['review']);

      return reviewData;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<RecentPropertyReviewsResponse> getRecentPropertyReviews(
    String propertyId,
    int limit,
    String token,
  ) async {
    try {
      final res = await dio.get(
        '/review/property/$propertyId/?limit=$limit',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final recentPropertyReviewsResponse =
          RecentPropertyReviewsResponse.fromJson(decodedBody);

      return recentPropertyReviewsResponse;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Chat> initializeChat(String propertyId, String token) async {
    try {
      final res = await dio.post(
        '/chat/initialize',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'propertyId': propertyId,
        },
      );

      final decodedBody = res.data;

      final chat = Chat.fromJson(decodedBody['data']['chat']);

      return chat;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          status: 503,
          message: 'Unable to connect to the server',
        );
      }

      final errors = error.response;

      if (errors != null) {
        if (errors.statusCode.toString().startsWith('5')) {
          throw ServerException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (errors.statusCode.toString().startsWith('4')) {
          throw UserException(
            status: errors.statusCode,
            message: errors.data['message'],
          );
        }

        if (!errors.statusCode.toString().startsWith('2')) {
          throw Exception('An error occurred');
        }
      }

      rethrow;
    } on SocketException catch (_) {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }
}
