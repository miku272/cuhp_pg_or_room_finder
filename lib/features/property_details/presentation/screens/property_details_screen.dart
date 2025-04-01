import 'package:flutter/material.dart';

import '../../../../core/common/entities/property.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;
  final Property property;

  const PropertyDetailsScreen({
    required this.propertyId,
    required this.property,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomAppBar(
          appBarTitle: property.propertyName!,
        ),
      ],
    );
  }
}
