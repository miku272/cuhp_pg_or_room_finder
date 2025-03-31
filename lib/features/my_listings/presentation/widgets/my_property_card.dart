import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/common/widgets/property_card.dart';
import '../../../property_listings/data/models/property_form_data.dart';
import '../bloc/my_listings_bloc.dart';

class MyPropertyCard extends StatelessWidget {
  final Property property;
  final Function(String propertyId) togglePropertyActivation;

  const MyPropertyCard({
    super.key,
    required this.property,
    required this.togglePropertyActivation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myListingBlocState = context.read<MyListingsBloc>().state;

    return Column(
      children: [
        PropertyCard(
          showFavouriteButton: false,
          images: property.images ?? [],
          propertyName: property.propertyName ?? 'Unnamed Property',
          address:
              '${property.propertyAddressLine1}, ${property.propertyVillageOrCity}',
          price: property.pricePerMonth!,
          isVerified: property.isVerified ?? false,
          propertyGenderAllowance: Property.genderAllowanceToString(
            property.propertyGenderAllowance ?? GenderAllowance.coEd,
          ),
          services: property.services ?? {},
          distanceFromUniversity:
              (property.distanceFromUniversity ?? 0).toDouble(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final propertyFormData = PropertyFormData(
                    id: property.id,
                    ownerId: property.ownerId,
                    propertyName: property.propertyName,
                    propertyAddressLine1: property.propertyAddressLine1,
                    propertyAddressLine2: property.propertyAddressLine2,
                    propertyVillageOrCity: property.propertyVillageOrCity,
                    propertyPincode: property.propertyPincode,
                    ownerName: property.ownerName,
                    ownerPhone: property.ownerPhone,
                    ownerEmail: property.ownerEmail,
                    pricePerMonth: property.pricePerMonth,
                    propertyType: property.propertyType,
                    propertyGenderAllowance: property.propertyGenderAllowance,
                    rentAgreementAvailable: property.rentAgreementAvailable,
                    coordinates: property.coordinates,
                    distanceFromUniversity: property.distanceFromUniversity,
                    services: property.services,
                    roomIds: property.roomIds,
                    images: property.images,
                    isVerified: property.isVerified,
                    isActive: property.isActive,
                    createdAt: property.createdAt,
                    updatedAt: property.updatedAt,
                  );

                  context.push(
                    '/add-property',
                    extra: <String, dynamic>{
                      'isEditing': true,
                      'propertyFormData': propertyFormData,
                    },
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: myListingBlocState is PropertyLoading
                    ? null
                    : () => togglePropertyActivation(property.id!),
                icon: myListingBlocState is PropertyLoading &&
                        myListingBlocState.propertyId == property.id!
                    ? null
                    : Icon(
                        property.isActive ?? true
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                label: myListingBlocState is PropertyLoading &&
                        myListingBlocState.propertyId == property.id
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        property.isActive ?? true ? 'Deactivate' : 'Activate',
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: property.isActive ?? true
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
