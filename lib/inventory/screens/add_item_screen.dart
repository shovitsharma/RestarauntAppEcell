import 'package:flutter/material.dart';
import 'package:untitled2/auth/widgets/form_helpers.dart'; // Use the styled widgets
import 'package:untitled2/utils/snackbar_helper.dart';   // Use the styled snackbar

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  final List<String> _categories = ['Appetizers', 'Main Course', 'Sides', 'Desserts', 'Beverages'];
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  var _imageFile; // Using 'var' for now as a placeholder

void _pickImage() {
  // This is a placeholder. The other dev will implement this.
  setState(() {
    _imageFile = 'dummy_path/image.jpg'; // Simulate picking an image
  });
  print('UI: Pick image from gallery pressed.');
}

  void _saveMenuItem() {
    // Placeholder logic for UI task. The other dev will add Firebase logic.
    final name = _nameController.text;
    if (name.isEmpty || _selectedCategory == null) {
      showCustomSnackBar(context, message: 'Please enter a name and select a category.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    // Simulate a network call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        print('UI: "Save Menu Item" button pressed for item: $name');
        showCustomSnackBar(context, message: '$name created (UI only)');
        Navigator.of(context).pop();
      }
    });
  }
  

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Add New Menu Item')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 9. NEW IMAGE UPLOAD SECTION ---
          const Text('Display Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _imageFile == null
                  ? const Text('No image selected.')
                  // In a real app, you'd use Image.file(_imageFile)
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Upload from Gallery'),
            onPressed: _pickImage,
          ),
          const Divider(height: 32, thickness: 1),

          const Text('Dish Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
            
            // Use the styled MyTextField from form_helpers.dart
            MyTextField(controller: _nameController, hintText: 'Dish Name (e.g., "Classic Burger")', obscureText: false),
            const SizedBox(height: 16),
            MyTextField(controller: _descriptionController, hintText: 'A short, tasty description', obscureText: false),
            const SizedBox(height: 16),
            MyTextField(controller: _priceController, hintText: 'Price (e.g., 10.99)', obscureText: false, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 20),

            Text('Category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Use a styled DropdownButton
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select a Category'),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            Text('Display Image', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            MyTextField(controller: _imageUrlController, hintText: 'Image URL (optional)', obscureText: false),
            
            const SizedBox(height: 32),
            
            // Use the styled MyButton which handles the loading state
            MyButton(
              onTap: _saveMenuItem,
              text: 'Save Menu Item',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}