import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_theme/theme_cubit.dart';
import '../../../../core/common/cubits/app_theme/theme_state.dart';

import '../widgets/category_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          elevation: 4,
          child: AppBar(
            toolbarHeight: 80,
            title: const Text('CUHP PG or Room Finder'),
            actions: <Widget>[
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) => IconButton(
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  icon: Icon(
                      state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: const <Widget>[
                      CategoryCard(
                        icon: Icons.home,
                        title: 'All',
                        color: Color.fromARGB(255, 137, 182, 77),
                      ),
                      CategoryCard(
                        icon: Icons.house,
                        title: 'PG',
                        color: Color(0xFF1E824C),
                      ),
                      CategoryCard(
                        icon: Icons.apartment,
                        title: 'Rooms',
                        color: Color(0xFF4DB6AC),
                      ),
                      CategoryCard(
                        icon: Icons.map,
                        title: 'Near Me',
                        color: Color(0xFF1E824C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: <Widget>[
                        FilterChip(
                          label: Text('Under ₹5000'),
                          onSelected: (bool selected) {},
                        ),
                        FilterChip(
                          label: Text('Verified Only'),
                          onSelected: (bool selected) {},
                        ),
                        FilterChip(
                          label: Text('With Food'),
                          onSelected: (bool selected) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: <Widget>[
                        FilterChip(
                          label: Text('Boys'),
                          onSelected: (bool selected) {},
                        ),
                        FilterChip(
                          label: Text('Girls'),
                          onSelected: (bool selected) {},
                        ),
                        FilterChip(
                          label: Text('Co-ed'),
                          onSelected: (bool selected) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search properties...',
                            prefixIcon: Icon(Icons.search),
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
                  // todo: Add property list here
                  const SizedBox(height: 24),
                  const Text(
                    'Featured Properties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      PropertyCard(
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
                      PropertyCard(
                        images: [
                          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
                          'https://images.unsplash.com/photo-1560448075-bb485b067938',
                        ],
                        propertyName: 'Mountain View Rooms',
                        address: 'McLeodganj',
                        price: 7500,
                        isVerified: true,
                        propertyGenderAllowance: 'co-ed',
                        services: {
                          'food': false,
                          'internet': true,
                          'parking': true,
                        },
                        distanceFromUniversity: 3.2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
