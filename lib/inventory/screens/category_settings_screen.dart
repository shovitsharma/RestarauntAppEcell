import 'package:flutter/material.dart';
import 'package:untitled2/auth/widgets/form_helpers.dart';
import 'package:untitled2/utils/snackbar_helper.dart';

class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({super.key});
  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  // Master list of categories. In the real app, this will come from Firebase.
  final List<String> _categories = ['Appetizer', 'Main Course', 'Sides', 'Dessert', 'Beverages'];
  final _newCategoryController = TextEditingController();

  void _addCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        _newCategoryController.clear();
      });
      showCustomSnackBar(context, message: '"$newCategory" added successfully.');
    } else {
      showCustomSnackBar(context, message: 'Category is empty or already exists.', isError: true);
    }
  }

  void _deleteCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
    showCustomSnackBar(context, message: '"$category" removed.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(category, style: Theme.of(context).textTheme.titleMedium),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteCategory(category),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // A more robust "Add" form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Category', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _newCategoryController,
                  hintText: 'e.g., "Curry" or "Salads"',
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                MyButton(
                  onTap: _addCategory,
                  text: 'Add Category',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}