import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/common/widgets/property_card.dart'; // Import PropertyCard
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory =
      'All'; // To keep track of the selected category pill

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: <Widget>[
          CustomAppBar(
            appBarTitle: 'CUHP PG or Room Finder',
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  context.push('/chat');
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Category Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory == 'All',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = 'All');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('PG'),
                            selected: _selectedCategory == 'PG',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = 'PG');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Rooms'),
                            selected: _selectedCategory == 'Rooms',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = 'Rooms');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Near Me'),
                            selected: _selectedCategory == 'Near Me',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = 'Near Me');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Bar and Filter Button
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search properties...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => const FilterBottomSheet(),
                            );
                          },
                          icon: const Icon(Icons.tune),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Placeholder for Featured Properties
                    const Text(
                      'Featured Properties',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const PropertyCard(
                      images: [
                        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
                        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af',
                      ],
                      propertyName: 'Sunshine PG Home',
                      address: 'Near CUHP Main Gate',
                      price: 5000,
                      isVerified: true,
                      propertyGenderAllowance: 'boys',
                      services: {
                        'food': true,
                        'internet': true,
                        'parking': true,
                      },
                      distanceFromUniversity: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
