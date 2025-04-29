import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/entities/property.dart';
import '../../data/models/property_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final PropertyFilter initialFilter;

  const FilterBottomSheet({required this.initialFilter, super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late double _maxDistance;
  late PropertyType? _selectedPropertyType;
  late GenderAllowance? _selectedGenderAllowance;
  late Set<String> _selectedServices;
  late bool _rentAgreementAvailable;
  late bool _isVerified;
  // Add other filter properties if needed (e.g., sortBy)

  @override
  void initState() {
    super.initState();

    final filter = widget.initialFilter;
    _priceRange = RangeValues(
      filter.minPrice ?? 1000,
      filter.maxPrice ?? 20000,
    );
    _maxDistance = filter.maxDistance ?? 5.0;
    _selectedPropertyType = filter.propertyType;
    _selectedGenderAllowance = filter.genderAllowance;
    _selectedServices = Set<String>.from(filter.services ?? []);
    _rentAgreementAvailable = filter.rentAgreementAvailable ?? false;
    _isVerified = filter.isVerified ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const double fabBottomMargin = 16.0;

    const double buttonHeight = 48.0;
    const double buttonBottomSpacing = 16.0;

    final String selectedPropertyTypeString = _selectedPropertyType == null
        ? 'All'
        : Property.propertyTypeToString(_selectedPropertyType!);
    final String? selectedGenderAllowanceString =
        _selectedGenderAllowance == null
            ? null
            : Property.genderAllowanceToString(_selectedGenderAllowance!);

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
        child: Stack(
          children: [
            ListView(
              controller: controller,
              padding: EdgeInsets.only(
                bottom: bottomPadding +
                    buttonHeight +
                    buttonBottomSpacing +
                    fabBottomMargin,
              ),
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 40,
                      height: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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
                  divisions: 30,
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
                      label: const Text('All'),
                      selected: selectedPropertyTypeString == 'All',
                      onSelected: (selected) {
                        if (selected) {
                          setState(
                            () => _selectedPropertyType = null,
                          );
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('PG'),
                      selected: selectedPropertyTypeString == 'pg',
                      onSelected: (selected) {
                        if (selected) {
                          setState(
                              () => _selectedPropertyType = PropertyType.pg);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Rooms'),
                      selected: selectedPropertyTypeString == 'room',
                      onSelected: (selected) {
                        if (selected) {
                          setState(
                              () => _selectedPropertyType = PropertyType.room);
                        }
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
                      label: const Text('Any'),
                      selected: selectedGenderAllowanceString == null,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedGenderAllowance = null;
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Boys'),
                      selected: selectedGenderAllowanceString == 'boys',
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedGenderAllowance = GenderAllowance.boys;
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Girls'),
                      selected: selectedGenderAllowanceString == 'girls',
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedGenderAllowance = GenderAllowance.girls;
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Co-ed'),
                      selected: selectedGenderAllowanceString == 'co-ed',
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedGenderAllowance = GenderAllowance.coEd;
                          });
                        }
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
                    for (String service in [
                      'food',
                      'water',
                      'electricity',
                      'internet',
                      'laundry',
                      'parking'
                    ])
                      FilterChip(
                        label: Text(
                            service[0].toUpperCase() + service.substring(1)),
                        selected: _selectedServices.contains(service),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
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

                const SizedBox(height: 80),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomPadding + fabBottomMargin + buttonHeight + 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  final filter = PropertyFilter(
                    minPrice: _priceRange.start,
                    maxPrice: _priceRange.end,
                    maxDistance: _maxDistance,
                    propertyType: _selectedPropertyType,
                    genderAllowance: _selectedGenderAllowance,
                    services: _selectedServices.isEmpty
                        ? null
                        : _selectedServices.toList(),
                    rentAgreementAvailable: _rentAgreementAvailable,
                    isVerified: _isVerified,
                    nearMeLat: widget.initialFilter.nearMeLat,
                    nearMeLng: widget.initialFilter.nearMeLng,
                    nearMeRadius: widget.initialFilter.nearMeRadius,
                    sortBy: widget.initialFilter.sortBy,
                  );

                  context.pop(filter);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
