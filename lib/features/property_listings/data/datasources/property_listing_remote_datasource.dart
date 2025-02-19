import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/common/entities/coordinate.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exception.dart';

import '../models/property_form_data.dart';
import '../models/property_listing_model.dart';

abstract class PropertyListingRemoteDataSource {
  Future<Property> addPropertyListing(
    PropertyFormData propertyFormData,
    String token,
    String userId,
    String username,
  );
}

class PropertyListingRemoteDataSourceImpl
    implements PropertyListingRemoteDataSource {
  @override
  Future<Property> addPropertyListing(
    PropertyFormData propertyFormData,
    String token,
    String userId,
    String userName,
  ) async {
    try {
      final res = await http
          .post(
        Uri.parse('${Constants.backendUri}/add-property'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          '_id': userId,
          'propertyName': propertyFormData.propertyName,
          'propertyAddressLine1': propertyFormData.propertyAddressLine1,
          'propertyAddressLine2': propertyFormData.propertyAddressLine2,
          'propertyVillageOrCity': propertyFormData.propertyVillageOrCity,
          'propertyPincode': propertyFormData.propertyPincode,
          'ownerName': userName,
          'ownerPhone': propertyFormData.ownerPhone,
          'ownerEmail': propertyFormData.ownerEmail,
          'propertyType': Property.propertyTypeToString(
            propertyFormData.propertyType!,
          ),
          'propertyGenderAllowance': Property.genderAllowanceToString(
            propertyFormData.propertyGenderAllowance!,
          ),
          'rentAgreementAvailable': propertyFormData.rentAgreementAvailable,
          'coordinates': propertyFormData.coordinates,
          'commonAminities': propertyFormData.services,
          'images': propertyFormData.images,
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw const SocketException('Connection timed out');
      });

      final decodedBody = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode.toString().startsWith('5')) {
        throw ServerException(
          status: res.statusCode,
          message: decodedBody['message'],
        );
      }

      if (res.statusCode.toString().startsWith('4')) {
        throw UserException(
          status: res.statusCode,
          message: decodedBody['message'],
        );
      }

      if (!res.statusCode.toString().startsWith('2')) {
        throw Exception('An error occurred');
      }

      print(decodedBody);

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
        propertyType: Property.propertyTypeFromString(
          decodedBody['data']['property']['propertyType'],
        ),
        propertyGenderAllowance: Property.genderAllowanceFromString(
          decodedBody['data']['property']['propertyGenderAllowance'],
        ),
        rentAgreementAvailable: decodedBody['data']['property']
            ['rentAgreementAvailable'],
        coordinates: Coordinate.fromJson(
          decodedBody['data']['property']['coordinates'] as Map<String, double>,
        ),
        distanceFromUniversity: decodedBody['data']['property']
            ['distanceFromUniversity'],
        services:
            decodedBody['data']['property']['services'] as Map<String, bool>,
        images: List<String>.from(decodedBody['data']['property']['images']),
        roomIds: List<String>.from(decodedBody['data']['property']['rooms']),
        isVerified: decodedBody['data']['property']['isVerified'],
        isActive: decodedBody['data']['property']['isActive'],
        createdAt: DateTime.parse(decodedBody['data']['property']['createdAt']),
        updatedAt: DateTime.parse(decodedBody['data']['property']['updatedAt']),
      );

      return propertyListing;
    } on SocketException {
      throw ServerException(
        status: 503,
        message: 'Unable to connect to the server',
      );
    } catch (error) {
      rethrow;
    }
  }
}
