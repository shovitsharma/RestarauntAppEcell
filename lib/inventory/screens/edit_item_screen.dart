import 'package:flutter/material.dart';
import 'package:untitled2/auth/widgets/form_helpers.dart'; // Reuse the widgets

class EditItemScreen extends StatefulWidget {
  // This screen will receive the item data from the list screen
  final Map<String, dynamic> item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with the item's data when the screen loads
    _nameController.text = widget.item['name'];
    _quantityController.text = widget.item['quantity'].toString();
    _unitController.text = widget.item['unit'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _updateItem() {
  // Create a map of the updated data
  final updatedItemData = {
    // You'll need an 'id' to find the item in the list later
    'id': widget.item['id'], 
    'name': _nameController.text,
    'quantity': double.parse(_quantityController.text),
    'unit': _unitController.text, // For simplicity, we're not using a dropdown here yet
  };
  
  // Pop the screen and pass the updated data back
  Navigator.of(context).pop({'action': 'update', 'data': updatedItemData});
}

void _deleteItem() {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Are you sure?'),
      content: Text('Do you want to permanently delete "${widget.item['name']}"?'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
          onPressed: () {
            // Pop the dialog, then pop the screen with a "delete" signal
            Navigator.of(ctx).pop(); 
            Navigator.of(context).pop({'action': 'delete', 'id': widget.item['id']});
          },
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.item['name']}'),
        actions: [
          // Add a delete button to the app bar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteItem,
            tooltip: 'Delete Item',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              MyTextField(
                controller: _nameController,
                hintText: 'Item Name',
                obscureText: false,
              ),
              const SizedBox(height: 16),
              MyTextField(
                controller: _quantityController,
                hintText: 'Quantity',
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              MyTextField(
                controller: _unitController,
                hintText: 'Unit',
                obscureText: false,
              ),
              const SizedBox(height: 32),
              MyButton(
                onTap: _updateItem,
                text: 'Update Item',
              ),
            ],
          ),
        ),
      ),
    );
  }
}