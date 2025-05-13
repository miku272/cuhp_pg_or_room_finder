import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String appBarTitle;
  final List<Widget>? actions;

  const CustomAppBar({required this.appBarTitle, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AppBar(
        toolbarHeight: 80,
        title: Text(appBarTitle),
        actions: actions,
      ),
    );
  }
}
