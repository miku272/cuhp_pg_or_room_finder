import 'package:flutter/material.dart';

import '../../data/models/property_form_data.dart';

import './add_property_screen_step_2.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  PropertyType _selectedPropertyType = PropertyType.building;
  GenderAllowance _selectedGenderAllowance = GenderAllowance.coEd;

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyAddressController.dispose();
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
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
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
                              controller: _propertyAddressController,
                              decoration: InputDecoration(
                                labelText: 'Property Address',
                                prefixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              maxLines: 3,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter property address'
                                  : null,
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
                            builder: (context) => AddPropertyScreenStep2(),
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
