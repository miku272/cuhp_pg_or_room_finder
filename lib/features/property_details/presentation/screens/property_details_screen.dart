import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/property.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';

import '../../../../core/utils/jwt_expiration_handler.dart';
import '../../../../init_dependencies.dart';
import '../bloc/property_details_bloc.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;
  final Property property;

  const PropertyDetailsScreen({
    required this.propertyId,
    required this.property,
    super.key,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late String userToken;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    final user = context.read<AppUserCubit>().user;

    if (user == null) {
      context.pop();

      return;
    }

    userToken = user.jwtToken;

    context.read<PropertyDetailsBloc>().add(
          UpdateProperty(property: widget.property),
        );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  Future<void> _launchMapsDirections(
    BuildContext context,
    Property property,
  ) async {
    if (property.coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No coordinates available')),
      );

      return;
    }

    final lat = property.coordinates!.lat;
    final lng = property.coordinates!.lng;

    late Uri mapUrl;

    if (Platform.isAndroid) {
      mapUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    } else if (Platform.isIOS) {
      mapUrl = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    }

    try {
      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(mapUrl);
      } else {
        final webUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
        );

        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(microseconds: 1));

    if (mounted) {
      context.read<PropertyDetailsBloc>().add(GetPropertyDetailsEvent(
            propertyId: widget.propertyId,
            token: userToken,
          ));

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Property property;
    return BlocConsumer<PropertyDetailsBloc, PropertyDetailsState>(
      listener: (context, state) {
        if (state is PropertyDetailsFailure) {
          if (state.status == 401) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            serviceLocator<JwtExpirationHandler>().stopExpiryCheck();
            context.read<AppUserCubit>().logoutUser(context);

            return;
          }
        }
      },
      builder: (context, state) {
        property = state.property ?? widget.property;

        if (state is PropertyDetailsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is PropertyDetailsFailure) {
          return const Center(
            child: Text('Failed to load property details'),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                CustomAppBar(
                  appBarTitle:
                      widget.property.propertyName ?? 'Property Details',
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property Images Carousel
                          _buildImageCarousel(context, property),

                          // Property Header Section
                          _buildPropertyHeader(context, property),

                          // Property Details
                          _buildDetailsSection(context, property),

                          // Property Amenities
                          _buildAmenitiesSection(context, property),

                          // Property Location
                          _buildLocationSection(context, property),

                          // Owner Details
                          _buildOwnerSection(context, property),

                          // Add some padding at the bottom to ensure content isn't hidden by the bottom buttons
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Fixed buttons at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildContactButtons(context, property),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageCarousel(BuildContext context, Property property) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 250,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            autoPlay: property.images != null && property.images!.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          items: (property.images ?? []).isEmpty
              ? [
                  Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  )
                ]
              : property.images!.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheHeight: 500,
                        memCacheWidth: 1000,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surface,
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                  );
                }).toList(),
        ),

        // Verification badge
        if (property.isVerified == true)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified,
                      color: theme.colorScheme.onPrimary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Image counter
        if ((property.images ?? []).length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${property.images?.length ?? 0} Photos',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyHeader(BuildContext context, Property property) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  property.propertyName ?? 'Unnamed Property',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  Property.propertyTypeToString(
                          property.propertyType ?? PropertyType.room)
                      .toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${property.propertyAddressLine1 ?? ''}, ${property.propertyVillageOrCity ?? ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                label: Text(
                  Property.genderAllowanceToString(
                          property.propertyGenderAllowance ??
                              GenderAllowance.coEd)
                      .toUpperCase(),
                ),
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              if (property.distanceFromUniversity != null)
                Chip(
                  label: Text('${property.distanceFromUniversity}KM FROM CUHP'),
                  backgroundColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.1,
                  ),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${property.pricePerMonth ?? 0}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / month',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Property property) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(
                  context,
                  Icons.house,
                  'Type',
                  Property.propertyTypeToString(
                      property.propertyType ?? PropertyType.room),
                ),
                _buildDetailItem(
                  context,
                  Icons.people,
                  'For',
                  Property.genderAllowanceToString(
                      property.propertyGenderAllowance ?? GenderAllowance.coEd),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(
                  context,
                  Icons.directions_walk,
                  'Distance',
                  '${property.distanceFromUniversity ?? 'N/A'} km',
                ),
                _buildDetailItem(
                  context,
                  Icons.description_outlined,
                  'Agreement',
                  property.rentAgreementAvailable == true
                      ? 'Available'
                      : 'Not Available',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (property.propertyAddressLine2 != null &&
                property.propertyAddressLine2!.isNotEmpty)
              Text(
                'Address: ${property.propertyAddressLine1}, ${property.propertyAddressLine2}, ${property.propertyVillageOrCity}, ${property.propertyPincode}',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(BuildContext context, Property property) {
    final theme = Theme.of(context);
    final services = property.services ?? {};

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amenities',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (services['food'] == true)
                    _buildAmenityChip(context, 'Food', Icons.restaurant),
                  if (services['internet'] == true)
                    _buildAmenityChip(context, 'Internet', Icons.wifi),
                  if (services['parking'] == true)
                    _buildAmenityChip(context, 'Parking', Icons.local_parking),
                  if (services['ac'] == true)
                    _buildAmenityChip(context, 'AC', Icons.ac_unit),
                  if (services['tv'] == true)
                    _buildAmenityChip(context, 'TV', Icons.tv),
                  if (services['laundry'] == true)
                    _buildAmenityChip(
                        context, 'Laundry', Icons.local_laundry_service),
                  if (services['cleaning'] == true)
                    _buildAmenityChip(
                        context, 'Cleaning', Icons.cleaning_services),
                  if (services['furniture'] == true)
                    _buildAmenityChip(context, 'Furniture', Icons.chair),
                  if (services['power_backup'] == true)
                    _buildAmenityChip(context, 'Power Backup', Icons.power),
                  if (services['security'] == true)
                    _buildAmenityChip(context, 'Security', Icons.security),
                  if (services['water'] == true)
                    _buildAmenityChip(context, 'Water', Icons.water_drop),
                  // Add other amenities as needed
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, Property property) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${property.propertyAddressLine1}, ${property.propertyAddressLine2 != null ? "${property.propertyAddressLine2}, " : ""}${property.propertyVillageOrCity}, ${property.propertyPincode}',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        property.coordinates!.lat.toDouble(),
                        property.coordinates!.lng.toDouble(),
                      ),
                      zoom: 15,
                    ),
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('property-location'),
                        position: LatLng(
                          property.coordinates!.lat.toDouble(),
                          property.coordinates!.lng.toDouble(),
                        ),
                        infoWindow: InfoWindow(
                          title: property.propertyName ?? 'Property Location',
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                      ),
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _launchMapsDirections(context, property),
                        icon: const Icon(Icons.directions, color: Colors.white),
                        label: const Text('Get Directions'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection(BuildContext context, Property property) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  radius: 24,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.ownerName ?? 'Owner Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (property.ownerPhone != null)
                        Text(
                          'Phone: ${property.ownerPhone}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (property.ownerEmail != null)
                        Text(
                          'Email: ${property.ownerEmail}',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButtons(BuildContext context, Property property) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: isDarkMode ? 1 : -5,
              offset: const Offset(0, -10),
            ),
            if (isDarkMode)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, -8),
              ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    var formattedNumber = property.ownerPhone!;

                    if (!formattedNumber.startsWith('+91')) {
                      formattedNumber = '+91$formattedNumber';
                    }

                    final Uri callUri = Uri(
                      scheme: 'tel',
                      path: formattedNumber,
                    );

                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(
                        callUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not launch phone dialer'),
                          ),
                        );
                      }
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not make the call'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(
                  Icons.phone,
                  color: Colors.white,
                ),
                label: Text(
                  'Call ${property.propertyName}',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement chat functionality
                },
                icon: const Icon(Icons.chat),
                label: Text(
                  'Chat with ${property.propertyName}',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
