import 'dart:io';

import 'package:image/image.dart' as img;

import 'package:flutter/foundation.dart';

class ImageUtils {
  static Future<String?> compressImage(String imageFilePath) async {
    return compute(_compressImage, imageFilePath);
  }

  static String? _compressImage(String imagePath) {
    // Read image file
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = imageFile.readAsBytesSync();

    // Decode and resize image
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage != null) {
      // Calculate aspect ratio to maintain image proportions
      final double aspectRatio = originalImage.width / originalImage.height;

      const int targetHeight = 400;
      final int targetWidth = (targetHeight * aspectRatio).round();

      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );

      // Compress with good quality for property listings
      final Uint8List compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 85, // Good quality for property images
      );

      // Save compressed image
      final String tempPath = imageFile.path.replaceAll(
        RegExp(r'\.[^.]*$'),
        '_compressed.jpg',
      );
      final File compressedFile = File(tempPath);
      compressedFile.writeAsBytesSync(compressedBytes);

      return compressedFile.path;
    } else {
      return null;
    }
  }
}
