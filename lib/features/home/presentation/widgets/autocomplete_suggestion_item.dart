import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/entities/property.dart';

class AutocompleteSuggestionItem extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const AutocompleteSuggestionItem(
      {required this.property, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                property.propertyType == PropertyType.pg
                    ? Icons.home_work_outlined
                    : Icons.room_outlined,
                color: theme.colorScheme.primary,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.propertyName ?? 'N/A',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.propertyAddressLine1 ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left side: Price and Distance
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.currency_rupee,
                                  size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 2),
                              Text(
                                property.pricePerMonth != null
                                    ? currencyFormatter
                                        .format(property.pricePerMonth)
                                    : 'N/A',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.social_distance_outlined,
                                  size: 14, color: theme.colorScheme.secondary),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  property.distanceFromUniversity != null
                                      ? '${property.distanceFromUniversity?.toStringAsFixed(1)} km'
                                      : 'N/A',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right side: Rating
                        if (property.averageRating != null &&
                            property.averageRating! > 0 &&
                            property.numberOfReviews != null &&
                            property.numberOfReviews! > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                  width: 8), // Spacer from left content
                              Icon(Icons.star_border_purple500_outlined,
                                  size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 2),
                              Text(
                                '${property.averageRating?.toStringAsFixed(1)} (${property.numberOfReviews})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
