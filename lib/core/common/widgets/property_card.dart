import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PropertyCard extends StatelessWidget {
  final List<String> images;
  final String propertyName;
  final String address;
  final int price;
  final bool isVerified;
  final String propertyGenderAllowance;
  final Map<String, bool> services;
  final double distanceFromUniversity;

  final bool showFavouriteButton;

  const PropertyCard({
    super.key,
    required this.images,
    required this.propertyName,
    required this.address,
    required this.price,
    required this.isVerified,
    required this.propertyGenderAllowance,
    required this.services,
    required this.distanceFromUniversity,
    this.showFavouriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData getGenderIcon(String gender) {
      switch (gender.toLowerCase()) {
        case 'boys':
          return Icons.male;
        case 'girls':
          return Icons.female;
        case 'co-ed':
        default:
          return Icons.wc;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: images.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheHeight: 400,
                        memCacheWidth: 800,
                        cacheKey: image,
                        maxHeightDiskCache: 400,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            height: 200,
                          ),
                        ),
                        fadeInDuration: const Duration(milliseconds: 300),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surface,
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              if (showFavouriteButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        propertyName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (isVerified)
                      Icon(
                        Icons.verified,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$address • ${distanceFromUniversity}km from CUHP',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      avatar: Icon(
                        getGenderIcon(propertyGenderAllowance),
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      label: Text(propertyGenderAllowance.toUpperCase()),
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.only(left: 4, right: 8),
                    ),
                    if (services['food'] == true)
                      Chip(
                        avatar: Icon(
                          Icons.food_bank_outlined,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        label: const Text('FOOD'),
                        backgroundColor: colorScheme.secondary.withOpacity(0.1),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelPadding: const EdgeInsets.only(left: 4, right: 8),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '₹$price / month',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
