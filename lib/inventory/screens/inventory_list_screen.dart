import 'package:flutter/material.dart';
import 'package:untitled2/inventory/models/category.dart';
import 'package:untitled2/inventory/models/inventory_item_model.dart'; 
import 'package:untitled2/inventory/services/inventory_service.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';
import 'settings_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});
  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final InventoryService _inventoryService = InventoryService();
  
  // State variables
  String _selectedCategory = 'All';
  bool _showVegOnly = false;

  // --- HELPER METHODS ---

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'main course': return Icons.restaurant;
      case 'appetizer': return Icons.tapas;
      case 'sides': return Icons.fastfood;
      case 'beverages': return Icons.local_cafe;
      case 'dessert': return Icons.cake;
      default: return Icons.restaurant_menu;
    }
  }

  // Toggle "Sold Out" status directly from the list
  void _toggleAvailability(String itemId, bool currentStatus) {
    _inventoryService.updateAvailability(itemId, !currentStatus);
  }

  // --- NAVIGATION METHODS ---

  void _navigateToAddItemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const AddItemScreen()),
    );
  }

  void _navigateToEditItemScreen(MenuItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => EditItemScreen(item: item)),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
             icon: const Icon(Icons.settings_outlined),
             onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. DYNAMIC CATEGORY CHIPS (Stream 1)
              StreamBuilder<List<CategoryModel>>(
                stream: _inventoryService.getCategories(),
                builder: (context, snapshot) {
                  // Default to just 'All' while loading or if empty
                  List<String> categoryNames = ['All'];
                  
                  if (snapshot.hasData) {
                    // Add categories from Firebase
                    categoryNames.addAll(snapshot.data!.map((e) => e.name));
                  }

                  return SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoryNames.length,
                      itemBuilder: (context, index) {
                        final category = categoryNames[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                               if (selected) setState(() => _selectedCategory = category);
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              ),

              // 2. MENU ITEMS LIST (Stream 2)
              Expanded(
                child: StreamBuilder<List<MenuItemModel>>(
                  stream: _inventoryService.getMenuItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No items found. Add some!'));
                    }

                    // Filter Data Locally
                    final allItems = snapshot.data!;
                    List<MenuItemModel> visibleItems = allItems;

                    // Filter by Category
                    if (_selectedCategory != 'All') {
                      visibleItems = visibleItems.where((item) => item.category == _selectedCategory).toList();
                    }

                    // Group Items by Category for the ListView
                    final Map<String, List<MenuItemModel>> groupedItems = {};
                    for (var item in visibleItems) {
                      if (groupedItems[item.category] == null) groupedItems[item.category] = [];
                      groupedItems[item.category]!.add(item);
                    }

                    final categoriesToDisplay = groupedItems.keys.toList()..sort();

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra padding at bottom for FABs
                      itemCount: categoriesToDisplay.length,
                      itemBuilder: (context, index) {
                        final category = categoriesToDisplay[index];
                        final items = groupedItems[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(category, style: Theme.of(context).textTheme.headlineSmall),
                            ),
                            ...items.map((item) => _buildMenuItemCard(item)).toList(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 3. FLOATING ACTION BUTTONS
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Veg Toggle (Visual Only for now)
                FloatingActionButton.extended(
                  onPressed: () => setState(() => _showVegOnly = !_showVegOnly),
                  icon: Icon(Icons.eco, color: _showVegOnly ? Colors.white : Colors.green),
                  label: Text('Veg Only', style: TextStyle(color: _showVegOnly ? Colors.white : Colors.black)),
                  backgroundColor: _showVegOnly ? Colors.green : Colors.white,
                  heroTag: 'vegToggle',
                ),
                // Add Item Button
                FloatingActionButton(
                  onPressed: _navigateToAddItemScreen,
                  tooltip: 'Add Menu Item',
                  child: const Icon(Icons.add),
                  heroTag: 'addItem',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _navigateToEditItemScreen(item), 
        leading: CircleAvatar(
          child: Icon(_getCategoryIcon(item.category)),
        ),
        title: Text(item.name),
        subtitle: Text('₹${item.price.toStringAsFixed(2)}'),
        trailing: Switch(
          value: item.isAvailable,
          onChanged: (val) => _toggleAvailability(item.id, item.isAvailable),
        ),
      ),
    );
  }
}