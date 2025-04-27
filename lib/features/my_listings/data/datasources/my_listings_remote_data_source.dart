import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/common/entities/coordinate.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/error/exception.dart';

abstract class MyListingsRemoteDataSource {
  Future<List<Property>> getPropertiesById(
    List<String> propertyIds,
    String token,
  );

  Future<Property> togglePropertyActivation(
    String propertyId,
    String token,
  );
}

class MyListingsRemoteDataSourceImpl implements MyListingsRemoteDataSource {
  final Dio dio;

  MyListingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Property>> getPropertiesById(
    List<String> propertyIds,
    String token,
  ) async {
    try {
      final res = await dio.post(
        '/get-properties-by-id',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
        data: {'propertyIds': propertyIds},
      );

      final decodedBody = res.data;

      List<Property> properties = [];

      for (final propertyData in decodedBody['data']['properties']) {
        final property = Property(
          id: propertyData['_id'],
          ownerId: propertyData['owner'],
          propertyName: propertyData['propertyName'],
          propertyAddressLine1: propertyData['propertyAddressLine1'],
          propertyAddressLine2: propertyData['propertyAddressLine2'],
          propertyVillageOrCity: propertyData['propertyVillageOrCity'],
          propertyPincode: propertyData['propertyPincode'],
          ownerName: propertyData['ownerName'],
          ownerPhone: propertyData['ownerPhone'],
          ownerEmail: propertyData['ownerEmail'],
          pricePerMonth: propertyData['pricePerMonth'],
          propertyType: Property.propertyTypeFromString(
            propertyData['propertyType'],
          ),
          propertyGenderAllowance: Property.genderAllowanceFromString(
            propertyData['propertyGenderAllowance'],
          ),
          rentAgreementAvailable: propertyData['rentAgreementAvailable'],
          coordinates: Coordinate(
            lat: propertyData['coordinates']['lat'],
            lng: propertyData['coordinates']['lng'],
          ),
          distanceFromUniversity: propertyData['distanceFromUniversity'],
          services: Map<String, bool>.from(propertyData['services']),
          images: List<String>.from(propertyData['images']),
          isVerified: propertyData['isVerified'],
          isActive: propertyData['isActive'],
          createdAt: DateTime.parse(propertyData['createdAt']),
          updatedAt: DateTime.parse(propertyData['updatedAt']),
        );

        properties.add(property);
      }

      return properties;
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
  Future<Property> togglePropertyActivation(
    String propertyId,
    String token,
  ) async {
    try {
      final res = await dio.get(
        '/toggle-property-activation/$propertyId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final decodedBody = res.data;

      final propertyListing = Property(
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

      return propertyListing;
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
}
