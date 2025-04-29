import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/common/entities/coordinate.dart';
import '../../../../core/common/entities/property.dart';

import '../../data/models/property_form_data.dart';

class AddPropertyScreen extends StatefulWidget {
  final bool isEditing;
  final PropertyFormData? property;

  const AddPropertyScreen({
    this.isEditing = false,
    this.property,
    super.key,
  });

  @override
  State<AddPropertyScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _propertyNameController = TextEditingController();
  final _propertyAddressLine1Controller = TextEditingController();
  final _propertyAddressLine2Controller = TextEditingController();
  final _propertyVillageOrCityController = TextEditingController();
  final _propertyPincodeController = TextEditingController();
  PropertyType _selectedPropertyType = PropertyType.pg;
  GenderAllowance _selectedGenderAllowance = GenderAllowance.coEd;

  num? chosenLng;
  num? chosenLat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _checkIfEditing();
      });
    });
  }

  void _checkIfEditing() {
    if (widget.isEditing == true && widget.property == null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
                canPop: false,
                child: AlertDialog(
                  title: const Text('Uh oh!'),
                  content: const Text(
                    'You are trying to edit an existing property but no property data was found',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ));
    }

    if (widget.isEditing == true && widget.property != null) {
      _propertyNameController.text = widget.property!.propertyName!;
      _propertyAddressLine1Controller.text =
          widget.property!.propertyAddressLine1!;
      _propertyAddressLine2Controller.text =
          widget.property!.propertyAddressLine2!;
      _propertyVillageOrCityController.text =
          widget.property!.propertyVillageOrCity!;
      _propertyPincodeController.text = widget.property!.propertyPincode!;
      _selectedPropertyType = widget.property!.propertyType!;
      _selectedGenderAllowance = widget.property!.propertyGenderAllowance!;

      chosenLat = widget.property!.coordinates!.coordinates[1];
      chosenLng = widget.property!.coordinates!.coordinates[0];
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate() ||
        chosenLat == null ||
        chosenLng == null) {
      return;
    }

    final property = widget.isEditing && widget.property != null
        ? widget.property!.copyWith(
            propertyName: _propertyNameController.text,
            propertyAddressLine1: _propertyAddressLine1Controller.text,
            propertyAddressLine2: _propertyAddressLine2Controller.text,
            propertyVillageOrCity: _propertyVillageOrCityController.text,
            propertyPincode: _propertyPincodeController.text,
            propertyType: _selectedPropertyType,
            propertyGenderAllowance: _selectedGenderAllowance,
            coordinates: Coordinate(
              coordinates: [chosenLng!, chosenLat!],
            ),
          )
        : PropertyFormData(
            propertyName: _propertyNameController.text,
            propertyAddressLine1: _propertyAddressLine1Controller.text,
            propertyAddressLine2: _propertyAddressLine2Controller.text,
            propertyVillageOrCity: _propertyVillageOrCityController.text,
            propertyPincode: _propertyPincodeController.text,
            propertyType: _selectedPropertyType,
            propertyGenderAllowance: _selectedGenderAllowance,
            coordinates: Coordinate(
              coordinates: [chosenLng!, chosenLat!],
            ),
          );

    context.push('/add-property/step-2', extra: {
      'isEditing': widget.isEditing,
      'propertyFormData': property,
    });
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyAddressLine1Controller.dispose();
    _propertyAddressLine2Controller.dispose();
    _propertyVillageOrCityController.dispose();
    _propertyPincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.isEditing ? 'Update' : 'Add'} Your Property',
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.home_work_rounded,
                      size: 64,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Property Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step 1 of 3',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _propertyNameController,
                                decoration: InputDecoration(
                                  labelText: 'Property Name',
                                  prefixIcon: const Icon(Icons.house),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Please enter property name'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _propertyAddressLine1Controller,
                                decoration: InputDecoration(
                                  labelText: 'Address Line 1',
                                  prefixIcon: const Icon(Icons.location_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Please enter address line 1'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _propertyAddressLine2Controller,
                                decoration: InputDecoration(
                                  labelText: 'Address Line 2 (Optional)',
                                  prefixIcon: const Icon(Icons.location_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller:
                                          _propertyVillageOrCityController,
                                      decoration: InputDecoration(
                                        labelText: 'Village/City',
                                        prefixIcon:
                                            const Icon(Icons.location_city),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      validator: (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Please enter village or city'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _propertyPincodeController,
                                      decoration: InputDecoration(
                                        labelText: 'Pincode',
                                        prefixIcon: const Icon(Icons.pin_drop),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Please enter pincode';
                                        }
                                        if (value!.length != 6) {
                                          return 'Pincode must be 6 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Property Location',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: chosenLat == null
                                            ? Border.all(
                                                color:
                                                    theme.colorScheme.outline)
                                            : null,
                                        borderRadius: chosenLat == null
                                            ? BorderRadius.circular(12)
                                            : null,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          children: <Widget>[
                                            if (chosenLat != null &&
                                                chosenLng != null)
                                              GoogleMap(
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: LatLng(
                                                    chosenLat!.toDouble(),
                                                    chosenLng!.toDouble(),
                                                  ),
                                                  zoom: 15,
                                                ),
                                                mapToolbarEnabled: false,
                                                myLocationButtonEnabled: false,
                                                markers: {
                                                  Marker(
                                                    markerId: const MarkerId(
                                                        'property-location'),
                                                    position: LatLng(
                                                      chosenLat!.toDouble(),
                                                      chosenLng!.toDouble(),
                                                    ),
                                                    infoWindow: InfoWindow(
                                                      title: _propertyNameController
                                                              .text.isNotEmpty
                                                          ? _propertyNameController
                                                              .text
                                                          : 'Property Location',
                                                    ),
                                                    icon: BitmapDescriptor
                                                        .defaultMarkerWithHue(
                                                      BitmapDescriptor.hueGreen,
                                                    ),
                                                  ),
                                                },
                                              )
                                            else
                                              GestureDetector(
                                                onTap: () async {
                                                  Map<String, dynamic>?
                                                      locationData =
                                                      await context.push<
                                                          Map<String,
                                                              dynamic>?>(
                                                    '/maps',
                                                    extra: {
                                                      'lat': chosenLat,
                                                      'lng': chosenLng
                                                    },
                                                  );

                                                  if (locationData != null) {
                                                    setState(() {
                                                      chosenLat =
                                                          locationData['lat'];
                                                      chosenLng =
                                                          locationData['lng'];
                                                    });
                                                  }
                                                },
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 48,
                                                        color: theme
                                                            .colorScheme.primary
                                                            .withValues(
                                                                alpha: 0.5),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Select a location',
                                                        style: theme.textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (chosenLat != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  chosenLat = null;
                                                  chosenLng = null;
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    theme.colorScheme.error,
                                                foregroundColor:
                                                    theme.colorScheme.onError,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Remove Location',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextButton.icon(
                                              onPressed: () async {
                                                Map<String, dynamic>?
                                                    locationData =
                                                    await context.push<
                                                        Map<String, dynamic>?>(
                                                  '/maps',
                                                  extra: {
                                                    'lat': chosenLat,
                                                    'lng': chosenLng
                                                  },
                                                );

                                                if (locationData != null) {
                                                  setState(() {
                                                    chosenLat =
                                                        locationData['lat'];
                                                    chosenLng =
                                                        locationData['lng'];
                                                  });
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                foregroundColor:
                                                    theme.colorScheme.onPrimary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.edit_location_alt,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Update Location',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Property Specifications',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<PropertyType>(
                                value: _selectedPropertyType,
                                decoration: InputDecoration(
                                  labelText: 'Property Type',
                                  prefixIcon: const Icon(Icons.category),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: PropertyType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                        () => _selectedPropertyType = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<GenderAllowance>(
                                value: _selectedGenderAllowance,
                                decoration: InputDecoration(
                                  labelText: 'Gender Allowance',
                                  prefixIcon: const Icon(Icons.people),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: GenderAllowance.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name == 'coEd'
                                        ? 'co-ed'
                                        : type.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => _selectedGenderAllowance = value,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Next Step',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
