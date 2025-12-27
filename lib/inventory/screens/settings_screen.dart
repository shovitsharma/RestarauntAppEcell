import 'package:flutter/material.dart';
import 'category_settings_screen.dart'; 

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
          // Section for Menu settings
          _buildSectionHeader(context, 'Menu'),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add, remove, or modify food categories'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CategorySettingsScreen()),
              );
            },
          ),
          
          const Divider(),
          
          // Section for Restaurant settings
          _buildSectionHeader(context, 'Restaurant Details'),
          const ListTile(
            leading: Icon(Icons.store_outlined),
            title: Text('Restaurant Info'),
            subtitle: Text('Name, address, contact details'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: null, // Placeholder
          ),
          const ListTile(
            leading: Icon(Icons.money_outlined),
            title: Text('Currency & Taxes'),
            subtitle: Text('Set currency symbol and tax rates'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: null, // Placeholder
          ),

          const Divider(),

          // Section for App settings
          _buildSectionHeader(context, 'Application'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            value: false, // Placeholder value
            onChanged: (bool value) {
              
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}