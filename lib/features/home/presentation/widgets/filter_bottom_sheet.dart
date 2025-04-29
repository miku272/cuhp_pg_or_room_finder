import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(1000, 20000);
  double _maxDistance = 5.0;
  String? _selectedPropertyType; // null means 'All' or not selected
  String? _selectedGenderAllowance; // null means 'All' or not selected
  final Set<String> _selectedServices = {};
  bool _rentAgreementAvailable = false;
  bool _isVerified = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const fabHeightWithMargin = kFloatingActionButtonMargin + 56.0 + 16.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.only(
            bottom: bottomPadding + fabHeightWithMargin,
          ),
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Price Range Slider
            const Text('Price Range (Monthly)'),
            RangeSlider(
              values: _priceRange,
              min: 1000,
              max: 20000,
              divisions: 19,
              labels: RangeLabels(
                '₹${_priceRange.start.round()}',
                '₹${_priceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() => _priceRange = values);
              },
            ),

            // Distance Slider
            const SizedBox(height: 16),
            const Text('Distance from University'),
            Slider(
              value: _maxDistance,
              min: 0,
              max: 30,
              divisions: 10,
              label: '${_maxDistance.round()} km',
              onChanged: (double value) {
                setState(() => _maxDistance = value);
              },
            ),

            // Property Type
            const SizedBox(height: 16),
            const Text('Property Type'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('PG'),
                  selected: _selectedPropertyType == 'pg',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedPropertyType = selected ? 'pg' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Rooms'),
                  selected: _selectedPropertyType == 'room',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedPropertyType = selected ? 'room' : null;
                    });
                  },
                ),
              ],
            ),

            // Gender Allowance
            const SizedBox(height: 16),
            const Text('Gender Allowance'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Boys'),
                  selected: _selectedGenderAllowance == 'boys',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedGenderAllowance = selected ? 'boys' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Girls'),
                  selected: _selectedGenderAllowance == 'girls',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedGenderAllowance = selected ? 'girls' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Co-ed'),
                  selected: _selectedGenderAllowance == 'co-ed',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedGenderAllowance = selected ? 'co-ed' : null;
                    });
                  },
                ),
              ],
            ),

            // Services
            const SizedBox(height: 16),
            const Text('Services'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Food'),
                  selected: _selectedServices.contains('food'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add('food');
                      } else {
                        _selectedServices.remove('food');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Water'),
                  selected: _selectedServices.contains('water'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add('water');
                      } else {
                        _selectedServices.remove('water');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Electricity'),
                  selected: _selectedServices.contains('electricity'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add('electricity');
                      } else {
                        _selectedServices.remove('electricity');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Internet'),
                  selected: _selectedServices.contains('internet'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add('internet');
                      } else {
                        _selectedServices.remove('internet');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Laundry'),
                  selected: _selectedServices.contains('laundry'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add('laundry');
                      } else {
                        _selectedServices.remove('laundry');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Parking'),
                  selected: _selectedServices.contains('parking'),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add('parking');
                      } else {
                        _selectedServices.remove('parking');
                      }
                    });
                  },
                ),
              ],
            ),

            // Other Filters
            const SizedBox(height: 16),
            const Text('Other Options'),
            SwitchListTile(
              title: const Text('Rent Agreement Available'),
              value: _rentAgreementAvailable,
              onChanged: (bool value) {
                setState(() {
                  _rentAgreementAvailable = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Verified Property'),
              value: _isVerified,
              onChanged: (bool value) {
                setState(() {
                  _isVerified = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Apply filters - you would typically pass these values back
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
