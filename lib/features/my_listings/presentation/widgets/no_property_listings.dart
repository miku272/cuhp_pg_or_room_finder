import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoPropertyListings extends StatelessWidget {
  const NoPropertyListings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        const SizedBox(height: 40),
        Lottie.asset(
          'assets/animations/magnifying_not_found.json',
          height: 200,
          width: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        Text(
          'No Properties Found',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'You haven\'t listed any properties yet. Add your first property to get started.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
