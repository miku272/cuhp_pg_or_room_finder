import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';

import '../../data/models/property_form_data.dart';

class AddPropertyScreenStep2 extends StatefulWidget {
  final bool isEditing;
  final PropertyFormData propertyFormData;

  const AddPropertyScreenStep2({
    required this.isEditing,
    required this.propertyFormData,
    super.key,
  });

  @override
  State<AddPropertyScreenStep2> createState() => _AddPropertyScreenStep2State();
}

class _AddPropertyScreenStep2State extends State<AddPropertyScreenStep2> {
  User? user;

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
  void initState() {
    super.initState();

    final userState = context.read<AppUserCubit>().state;

    if (userState is AppUserLoggedin) {
      user = userState.user;

      _ownerNameController.text = user?.name ?? '';
      _ownerPhoneController.text = user?.phone ?? '';
      _ownerEmailController.text = user?.email ?? '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _checkIfEditing();
        });
      });
    } else {
      context.pop();
    }
  }

  void _checkIfEditing() {
    if (widget.isEditing) {
      _rentAgreementAvailable = widget.propertyFormData.rentAgreementAvailable!;

      widget.propertyFormData.services!.forEach((key, value) {
        if (_services.containsKey(key)) {
          _services[key] = value;
        }
      });
    }
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final property = widget.propertyFormData.copyWith(
      ownerName: _ownerNameController.text,
      ownerPhone: _ownerPhoneController.text,
      ownerEmail: _ownerEmailController.text,
      rentAgreementAvailable: _rentAgreementAvailable,
      services: _services,
    );

    context.push('/add-property/step-3', extra: {
      'isEditing': widget.isEditing,
      'propertyFormData': property,
    });
  }

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
                              enabled: user?.name == null,
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
                              enabled: user?.phone == null,
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
                              enabled: user?.email == null,
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
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
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
                            onPressed: _onNext,
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
