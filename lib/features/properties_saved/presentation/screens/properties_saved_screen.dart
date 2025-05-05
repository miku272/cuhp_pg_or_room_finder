import 'package:flutter/material.dart';

import '../../../../core/common/widgets/custom_app_bar.dart';

import '../widgets/no_properties_saved.dart';

class PropertiesSavedScreen extends StatelessWidget {
  const PropertiesSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        CustomAppBar(appBarTitle: 'My saved properties'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: NoPropertySaved(),
          ),
        ),
      ],
    );
  }
}
