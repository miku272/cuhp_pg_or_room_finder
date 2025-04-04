import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/coordinate.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/error/exception.dart';

import '../../../../core/utils/supabase_manager.dart';
import '../models/property_form_data.dart';
import '../models/property_listing_model.dart';

abstract class PropertyListingRemoteDataSource {
  Future<PropertyListingModel> addPropertyListing(
    PropertyFormData propertyFormData,
    List<File> images,
    String token,
    String userId,
    String username,
  );

  Future<PropertyListingModel> updatePropertyListing(
    String propertyId,
    PropertyFormData propertyFormData,
    List<File> images,
    List<String> imagesToDelete,
    String token,
    String username,
  );
}

class PropertyListingRemoteDataSourceImpl
    implements PropertyListingRemoteDataSource {
  final Dio dio;

  PropertyListingRemoteDataSourceImpl({required this.dio});

  @override
  Future<PropertyListingModel> addPropertyListing(
    PropertyFormData propertyFormData,
    List<File> images,
    String token,
    String userId,
    String userName,
  ) async {
    try {
      final List<String> imageUrls = await SupabaseManager.uploadImages(images);

      final res = await dio.post('/add-property',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
          data: {
            '_id': userId,
            'propertyName': propertyFormData.propertyName,
            'propertyAddressLine1': propertyFormData.propertyAddressLine1,
            'propertyAddressLine2': propertyFormData.propertyAddressLine2,
            'propertyVillageOrCity': propertyFormData.propertyVillageOrCity,
            'propertyPincode': propertyFormData.propertyPincode,
            'ownerName': userName,
            'ownerPhone': propertyFormData.ownerPhone!
                .replaceAll(RegExp(r'\s+'), '') // Remove all whitespace
                .replaceAll(RegExp(r'^\+91|^91'), ''),
            // Remove +91 or 91 prefix
            'ownerEmail': propertyFormData.ownerEmail,
            'pricePerMonth': propertyFormData.pricePerMonth,
            'propertyType': Property.propertyTypeToString(
              propertyFormData.propertyType!,
            ),
            'propertyGenderAllowance': Property.genderAllowanceToString(
              propertyFormData.propertyGenderAllowance!,
            ),
            'rentAgreementAvailable': propertyFormData.rentAgreementAvailable,
            'coordinates': propertyFormData.coordinates,
            'services': propertyFormData.services,
            'images': imageUrls,
          });

      final decodedBody = res.data;

      log(
        'Property listing remote data in add property listing: ',
        error: decodedBody['data']['property']['_id'],
      );

      final propertyListing = PropertyListingModel(
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
        roomIds: List<String>.from(decodedBody['data']['property']['rooms']),
        isVerified: decodedBody['data']['property']['isVerified'],
        isActive: decodedBody['data']['property']['isActive'],
        createdAt: DateTime.parse(decodedBody['data']['property']['createdAt']),
        updatedAt: DateTime.parse(decodedBody['data']['property']['updatedAt']),
      );

      return propertyListing;
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
  Future<PropertyListingModel> updatePropertyListing(
    String propertyId,
    PropertyFormData propertyFormData,
    List<File> images,
    List<String> imagesToDelete,
    String token,
    String username,
  ) async {
    try {
      if (imagesToDelete.isNotEmpty) {
        await SupabaseManager.deletePropertyImages(imagesToDelete);
      }
      final newUploadedImages = images.isEmpty
          ? <String>[]
          : await SupabaseManager.uploadImages(images);
      final imageUrls = [...newUploadedImages, ...propertyFormData.images!]
          .filter(
            (imageUrl) => !imagesToDelete.contains(imageUrl),
          )
          .toList();

      final res = await dio.post('/update-property',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
          data: {
            'propertyId': propertyId,
            'propertyName': propertyFormData.propertyName,
            'propertyAddressLine1': propertyFormData.propertyAddressLine1,
            'propertyAddressLine2': propertyFormData.propertyAddressLine2,
            'propertyVillageOrCity': propertyFormData.propertyVillageOrCity,
            'propertyPincode': propertyFormData.propertyPincode,
            'ownerName': username,
            'ownerPhone': propertyFormData.ownerPhone!
                .replaceAll(RegExp(r'\s+'), '') // Remove all whitespace
                .replaceAll(RegExp(r'^\+91|^91'), ''),
            // Remove +91 or 91 prefix
            'ownerEmail': propertyFormData.ownerEmail,
            'pricePerMonth': propertyFormData.pricePerMonth,
            'propertyType': Property.propertyTypeToString(
              propertyFormData.propertyType!,
            ),
            'propertyGenderAllowance': Property.genderAllowanceToString(
              propertyFormData.propertyGenderAllowance!,
            ),
            'rentAgreementAvailable': propertyFormData.rentAgreementAvailable,
            'coordinates': propertyFormData.coordinates,
            'services': propertyFormData.services,
            'images': imageUrls,
          });

      final decodedBody = res.data;

      log(
        'Property listing remote data in add property listing: ',
        error: decodedBody['data']['property']['_id'],
      );

      final propertyListing = PropertyListingModel(
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
        roomIds: List<String>.from(decodedBody['data']['property']['rooms']),
        isVerified: decodedBody['data']['property']['isVerified'],
        isActive: decodedBody['data']['property']['isActive'],
        createdAt: DateTime.parse(decodedBody['data']['property']['createdAt']),
        updatedAt: DateTime.parse(decodedBody['data']['property']['updatedAt']),
      );

      return propertyListing;
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
