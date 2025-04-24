import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/common/entities/coordinate.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/error/exception.dart';

abstract interface class PropertyDetailsRemoteDatasource {
  Future<Property> getPropertyDetails(String propertyId, String token);
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
          lat: decodedBody['data']['property']['coordinates']['lat'],
          lng: decodedBody['data']['property']['coordinates']['lng'],
        ),
        distanceFromUniversity: decodedBody['data']['property']
            ['distanceFromUniversity'],
        services:
            Map<String, bool>.from(decodedBody['data']['property']['services']),
        images: List<String>.from(decodedBody['data']['property']['images']),
        isVerified: decodedBody['data']['property']['isVerified'],
        isActive: decodedBody['data']['property']['isActive'],
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
}
