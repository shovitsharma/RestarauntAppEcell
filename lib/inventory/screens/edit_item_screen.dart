import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled2/auth/widgets/form_helpers.dart';
import 'package:untitled2/inventory/models/category.dart';
import 'package:untitled2/inventory/models/inventory_item_model.dart';
import 'package:untitled2/inventory/services/inventory_service.dart';
import 'package:untitled2/inventory/services/image_service.dart'; 
import 'package:untitled2/utils/snackbar_helper.dart';

class EditItemScreen extends StatefulWidget {
  final MenuItemModel item;
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final InventoryService _inventoryService = InventoryService();
  final ImageService _imageService = ImageService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  
  String? _selectedCategory;
  bool _isLoading = false;
  
  File? _newImageFile; 

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.item.name);
    _descController = TextEditingController(text: widget.item.description);
    _priceController = TextEditingController(text: widget.item.price.toString());
    _selectedCategory = widget.item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final File? image = await _imageService.pickImage();
    if (image != null) {
      setState(() {
        _newImageFile = image;
      });
    }
  }

  Future<void> _updateItem() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      showCustomSnackBar(context, message: 'Please fill required fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    String finalImageUrl = widget.item.imageUrl; 

    try {
      // 1. Check if user picked a NEW image
      if (_newImageFile != null) {
        final newUrl = await _imageService.uploadImage(_newImageFile!);
        if (newUrl != null) {
          finalImageUrl = newUrl;
        }
      }

      // 2. Prepare Updated Model
      final updatedItem = MenuItemModel(
        id: widget.item.id, // Keep original ID
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory!,
        imageUrl: finalImageUrl, // Use the determined URL
        isAvailable: widget.item.isAvailable,
      );

      // 3. Update in Firestore
      await _inventoryService.updateMenuItem(updatedItem);

      if (mounted) {
        Navigator.pop(context);
        showCustomSnackBar(context, message: 'Item updated successfully');
      }
    } catch (e) {
      if (mounted) showCustomSnackBar(context, message: 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
             onPressed: () => Navigator.pop(ctx, true), 
             child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _inventoryService.deleteMenuItem(widget.item.id);
        if (mounted) {
          Navigator.pop(context); // Close Edit Screen
          showCustomSnackBar(context, message: 'Item deleted');
        }
      } catch (e) {
        if (mounted) showCustomSnackBar(context, message: 'Error: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper to determine what image to show
    ImageProvider? displayImage;
    if (_newImageFile != null) {
      displayImage = FileImage(_newImageFile!); 
    } else if (widget.item.imageUrl.isNotEmpty) {
      displayImage = NetworkImage(widget.item.imageUrl); 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- IMAGE PICKER ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  image: displayImage != null 
                    ? DecorationImage(image: displayImage, fit: BoxFit.cover)
                    : null,
                ),
                child: displayImage == null
                    ? const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey))
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tap image to change', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),

            // --- FORM FIELDS ---
            MyTextField(controller: _nameController, hintText: 'Name', obscureText: false),
            const SizedBox(height: 16),
            MyTextField(controller: _descController, hintText: 'Description', obscureText: false),
            const SizedBox(height: 16),
            MyTextField(
               controller: _priceController, 
               hintText: 'Price', 
               obscureText: false, 
               keyboardType: TextInputType.number
            ),
            const SizedBox(height: 16),

            // --- CATEGORY DROPDOWN ---
            StreamBuilder<List<CategoryModel>>(
              stream: _inventoryService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final categories = snapshot.data!;
                
                return DropdownButtonFormField<String>(
                  value: categories.any((c) => c.name == _selectedCategory) ? _selectedCategory : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                );
              }
            ),

            const SizedBox(height: 32),
            MyButton(
              onTap: _updateItem, 
              text: 'Update Item',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}