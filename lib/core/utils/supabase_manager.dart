import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../error/exception.dart';

class SupabaseManager {
  static SupabaseClient? _client;
  static const String _bucketName = 'property-listing/property-images';

  static Future<void> initialize() async {
    if (_client != null) {
      return;
    }

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase URL and Supabase Anon Key are required');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  static Future<List<String>> uploadImages(List<File> images) async {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }

    final uploadedUrls = <String>[];
    final uploadedFileNames = <String>[];
    const uuid = Uuid();

    try {
      for (final image in images) {
        final fileExtension = path.extension(image.path);
        final fileName = '${uuid.v4()}$fileExtension';

        await _client!.storage.from(_bucketName).upload(
              fileName,
              image,
            );

        uploadedFileNames.add(fileName);
        final imageUrl =
            _client!.storage.from(_bucketName).getPublicUrl(fileName);
        uploadedUrls.add(imageUrl);
      }

      return uploadedUrls;
    } catch (error) {
      log('Error in uploading image: ', error: error);
      // Attempt to rollback - delete any uploaded files
      if (uploadedFileNames.isNotEmpty) {
        try {
          await _client!.storage.from(_bucketName).remove(uploadedFileNames);
        } catch (rollbackError) {
          log('Rollback failed: ', error: rollbackError);
          throw SupabaseException(
            message:
                'Upload failed and rollback failed. Some files may be orphaned.',
          );
        }
      }
      throw SupabaseException(message: 'Failed to upload images');
    }
  }

  static Future<void> deletePropertyImages(List<String> imageUrls) async {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }

    try {
      for (final imageUrl in imageUrls) {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;

        if (pathSegments.isEmpty) {
          throw SupabaseException(message: 'Invalid image URL');
        }

        final fileName = pathSegments.last;
        await _client!.storage.from('property-listing').remove(
          ['property-images/$fileName'],
        );
      }
    } catch (error) {
      log('Error in deleting images: ', error: error);
      throw SupabaseException(message: 'Failed to delete images');
    }
  }
}
