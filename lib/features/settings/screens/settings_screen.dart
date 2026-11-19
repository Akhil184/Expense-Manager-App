import 'package:flutter/material.dart';

import '../widgets/theme_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ThemeSettings(),
        ],
      ),
    );
  }
}