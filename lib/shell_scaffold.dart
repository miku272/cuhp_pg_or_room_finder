import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ShellScaffold({
    required this.child,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;

            case 1:
              context.go('/saved');
              break;

            case 2:
              context.go('/my-listings');
              break;

            case 3:
              context.go('/profile');
              break;
          }
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.real_estate_agent),
            label: 'My Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 0 || currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/add-property');
              },
              tooltip: 'Add Property',
              label: const Row(
                spacing: 10.0,
                children: <Widget>[
                  Icon(Icons.add),
                  Text('Add Property'),
                ],
              ),
            )
          : null,
    );
  }
}
