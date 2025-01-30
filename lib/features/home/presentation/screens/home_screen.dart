import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_theme/theme_cubit.dart';
import '../../../../core/common/cubits/app_theme/theme_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('CUHP PG or Room Finder'),
          actions: [
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) => IconButton(
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
                icon:
                    Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for rooms or PG...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Categories Section
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: const [
                    CategoryCard(
                      icon: Icons.house,
                      title: 'PG Accommodations',
                      color: Color(0xFF1E824C),
                    ),
                    CategoryCard(
                      icon: Icons.apartment,
                      title: 'Rooms',
                      color: Color(0xFF4DB6AC),
                    ),
                    CategoryCard(
                      icon: Icons.favorite,
                      title: 'Saved',
                      color: Color(0xFFFF9800),
                    ),
                    CategoryCard(
                      icon: Icons.map,
                      title: 'Near Me',
                      color: Color(0xFF1E824C),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
