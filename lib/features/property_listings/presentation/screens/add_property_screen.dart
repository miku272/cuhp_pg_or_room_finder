import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/common/entities/property.dart';

import 'add_property_screen_step_2.dart';
import 'map_screen.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

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
        title: const Text('Add Your Property'),
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
                                              Uint8List? snapshotData =
                                                  await Navigator.push<
                                                      Uint8List?>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MapScreen(),
                                                ),
                                              );

                                              if (snapshotData != null) {
                                                setState(() {
                                                  mapSnapshot = snapshotData;
                                                });
                                              }
                                            },
                                            child: mapSnapshot == null
                                                ? const Text('Show map')
                                                : Image.memory(
                                                    mapSnapshot!,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (mapSnapshot != null)
                                      const SizedBox(height: 16),
                                    if (mapSnapshot != null)
                                      ElevatedButton.icon(
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
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text(
                                          'Remove Location',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                                  child: Text(type.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(
                                      () => _selectedGenderAllowance = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // if (_formKey.currentState?.validate() ?? false) {
                        //   // Add your navigation logic here
                        // }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AddPropertyScreenStep2(),
                          ),
                        );
                      },
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
