import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:untitled2/auth/widgets/form_helpers.dart';
import 'package:untitled2/inventory/models/category.dart';
import 'package:untitled2/utils/snackbar_helper.dart';
import 'package:untitled2/inventory/services/inventory_service.dart';
import 'package:untitled2/inventory/models/inventory_item_model.dart';
import 'package:untitled2/inventory/services/image_service.dart'; 

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Services
  final InventoryService _inventoryService = InventoryService();
  final ImageService _imageService = ImageService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();


  // State Variables
  bool _isLoading = false;
  String? _selectedCategory;
  File? _selectedImage; 
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 1. Pick Image Logic
  Future<void> _pickImage() async {
    final File? image = await _imageService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // 2. Save Logic with Cloudinary Upload
  Future<void> _saveMenuItem() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final priceString = _priceController.text.trim();

    // Validation
    if (name.isEmpty || _selectedCategory == null || priceString.isEmpty) {
      if (mounted) showCustomSnackBar(context, message: 'Please fill in Name, Price and Category.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    String imageUrl = '';

try {
      // A. Upload Image to Cloudinary
      if (_selectedImage != null) {
        final url = await _imageService.uploadImage(_selectedImage!);
        
        if (url != null) {
          imageUrl = url;
        } else {
          // 1. Upload Failed: Stop everything and throw error
          throw Exception("Image upload failed. Please check your internet and try again.");
        }
      } else {
        // 2. No Image Selected: Stop everything and throw error
        throw Exception("An image is required. Please select a photo.");
      }

      // B. Create the Model
      final newItem = MenuItemModel(
        id: '', 
        name: name,
        description: description,
        price: double.tryParse(priceString) ?? 0.0,
        category: _selectedCategory!,
        imageUrl: imageUrl, 
        isAvailable: true,
      );

      // C. Send to Firebase
      await _inventoryService.addMenuItem(newItem);

      if (mounted) {
        showCustomSnackBar(context, message: '$name added to menu!');
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, message: 'Error adding item: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            // --- IMAGE PICKER SECTION ---
            const Text('Dish Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to upload photo', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const Divider(height: 40, thickness: 1),

            // --- FORM SECTION ---
            const Text('Dish Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            MyTextField(controller: _nameController, hintText: 'Dish Name', obscureText: false),
            const SizedBox(height: 16),
            MyTextField(controller: _descriptionController, hintText: 'Description', obscureText: false),
            const SizedBox(height: 16),
            MyTextField(
              controller: _priceController, 
              hintText: 'Price (e.g. 150)', 
              obscureText: false, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true)
            ),
            const SizedBox(height: 20),

            Text('Category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // --- CATEGORY DROPDOWN
            StreamBuilder<List<CategoryModel>>(
              stream: _inventoryService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                   return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No categories found. Go to Settings > Manage Categories.'),
                  );
                }

                final categories = snapshot.data!;
                
                // Safe Selection Logic
                final bool valueExistsInList = categories.any((c) => c.name == _selectedCategory);
                if (_selectedCategory != null && !valueExistsInList) {
                  _selectedCategory = null; 
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Select a Category'),
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.name,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                  validator: (value) => value == null ? 'Please select a category' : null,
                );
              }
            ),

            const SizedBox(height: 32),
            
            MyButton(
              onTap: _saveMenuItem,
              text: 'Save Menu Item',
              isLoading: _isLoading,
            ),
            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }
}