import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(1000, 20000);
  double _maxDistance = 5.0;

  @override
  Widget build(BuildContext context) {
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
              max: 10,
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
                  label: const Text('Building'),
                  selected: false,
                  onSelected: (bool selected) {},
                ),
                ChoiceChip(
                  label: const Text('Flat'),
                  selected: false,
                  onSelected: (bool selected) {},
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
                  selected: false,
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  label: const Text('Wifi'),
                  selected: false,
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  label: const Text('Parking'),
                  selected: false,
                  onSelected: (bool selected) {},
                ),
                // Add more service filters
              ],
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Apply filters
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
