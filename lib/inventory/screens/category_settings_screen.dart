import 'package:flutter/material.dart';
import 'package:untitled2/auth/widgets/form_helpers.dart'; 
import 'package:untitled2/inventory/models/category.dart';
import 'package:untitled2/inventory/services/inventory_service.dart';
import 'package:untitled2/utils/snackbar_helper.dart';   
class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({super.key});

  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  final InventoryService _inventoryService = InventoryService();
  final _newCategoryController = TextEditingController();
  
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isEmpty) return;

    // 1. START LOADING
    setState(() => _isProcessing = true); 

    try {
      await _inventoryService.addCategory(newCategory);
      
      _newCategoryController.clear();
      
      if (mounted) FocusScope.of(context).unfocus(); 
      if (mounted) showCustomSnackBar(context, message: 'Category added successfully!');
    
    } catch (e) {
      // 2. CATCH ERRORS (Check your debug console for the text printed here!)
      print('FAILED TO ADD CATEGORY: $e'); 
      if (mounted) showCustomSnackBar(context, message: 'Error: $e', isError: true);
    
    } finally {
      // 3. STOP LOADING (This runs whether it succeeds OR fails)
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    // 1. Show Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      // 2. Client-Side Check (Free Workaround)
      final isInUse = await _inventoryService.isCategoryInUse(category.name);

      if (isInUse) {
        if (mounted) {
          showCustomSnackBar(
            context,
            message: 'Cannot delete: Items exist in "${category.name}"!',
            isError: true,
          );
        }
      } else {
        // 3. SAFE: Proceed to delete
        await _inventoryService.deleteCategory(category.id);
        
        if (mounted) {
          showCustomSnackBar(context, message: 'Category deleted successfully.');
        }
      }
    } catch (e) {
      if (mounted) showCustomSnackBar(context, message: 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CategoryModel>>(
              stream: _inventoryService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories yet. Add one!'));
                }

                final categories = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      child: ListTile(
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          
                          onPressed: () => _deleteCategory(category),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Category', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _newCategoryController,
                  hintText: 'e.g., "Vegan Specials"',
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                MyButton(
                  onTap: _addCategory,
                  text: 'Add Category',
                  isLoading: _isProcessing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}