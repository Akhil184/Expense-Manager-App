import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette_outlined),
                SizedBox(width: 12),
                Text(
                  'Appearance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              subtitle: const Text('Follow device settings'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeProvider>().setThemeMode(value);
                }
              },
            ),

            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeProvider>().setThemeMode(value);
                }
              },
            ),

            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeProvider>().setThemeMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
