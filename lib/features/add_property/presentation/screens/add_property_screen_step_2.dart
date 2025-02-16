import 'package:flutter/material.dart';

import '../../data/models/property_form_data.dart';

import './add_property_screen_step_3.dart';

class AddPropertyScreenStep2 extends StatefulWidget {
  const AddPropertyScreenStep2({super.key});

  @override
  State<AddPropertyScreenStep2> createState() => _AddPropertyScreenStep2State();
}

class _AddPropertyScreenStep2State extends State<AddPropertyScreenStep2> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  bool _rentAgreementAvailable = false;
  final Map<String, bool> _services = {
    'food': false,
    'electricity': false,
    'water': false,
    'internet': false,
    'laundry': false,
    'parking': false,
  };

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
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
                    Icons.contact_phone_rounded,
                    size: 64,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contact Information',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step 2 of 3',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Owner Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ownerNameController,
                              decoration: InputDecoration(
                                labelText: 'Owner Name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter owner name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ownerPhoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter phone number'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ownerEmailController,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter email address'
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
                              'Available Services',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Rent Agreement Available'),
                              value: _rentAgreementAvailable,
                              onChanged: (bool value) {
                                setState(() {
                                  _rentAgreementAvailable = value;
                                });
                              },
                            ),
                            const Divider(),
                            ..._services.entries.map((service) {
                              return CheckboxListTile(
                                title: Text(service.key.toUpperCase()),
                                value: service.value,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    setState(() {
                                      _services[service.key] = value;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // if (_formKey.currentState?.validate() ?? false) {
                              //   // Add navigation logic here
                              // }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddPropertyScreenStep3(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Next Step'),
                          ),
                        ),
                      ],
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
