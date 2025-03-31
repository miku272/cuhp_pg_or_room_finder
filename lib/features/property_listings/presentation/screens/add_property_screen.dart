import 'dart:typed_data';

import 'package:cuhp_pg_or_room_finder/core/common/entities/coordinate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  Uint8List? mapSnapshot;

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

      chosenLat = widget.property!.coordinates!.lat;
      chosenLng = widget.property!.coordinates!.lng;
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate() ||
        (mapSnapshot == null && !widget.isEditing) ||
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
              lat: chosenLat!,
              lng: chosenLng!,
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
              lat: chosenLat!,
              lng: chosenLng!,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.isEditing ? 'Update' : 'Add'} Your Property',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
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
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) => value?.isEmpty ?? true
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
                                        borderRadius: BorderRadius.circular(12),
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
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                        border: mapSnapshot != null
                                            ? null
                                            : Border.all(
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                        borderRadius: mapSnapshot != null
                                            ? null
                                            : BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: mapSnapshot != null
                                            ? BorderRadius.zero
                                            : BorderRadius.circular(12),
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () async {
                                              Map<String, dynamic>?
                                                  snapshotData =
                                                  await context.push<
                                                      Map<String, dynamic>?>(
                                                '/maps',
                                                extra: {
                                                  'lat': chosenLat,
                                                  'lng': chosenLng
                                                },
                                              );

                                              if (snapshotData != null) {
                                                setState(() {
                                                  mapSnapshot =
                                                      snapshotData['snap'];

                                                  chosenLat =
                                                      snapshotData['lat'];
                                                  chosenLng =
                                                      snapshotData['lng'];
                                                });
                                              }
                                            },
                                            child: mapSnapshot == null
                                                ? const Text('Show map')
                                                : Image.memory(
                                                    mapSnapshot!,
                                                    fit: BoxFit.cover,
                                                    height: 200,
                                                    width: 350,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (mapSnapshot != null)
                                      const SizedBox(height: 16),
                                    if (mapSnapshot != null)
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              mapSnapshot = null;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            foregroundColor:
                                                theme.colorScheme.onError,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          label: const Text(
                                            'Remove Location',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  setState(() => _selectedPropertyType = value);
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
    );
  }
}
