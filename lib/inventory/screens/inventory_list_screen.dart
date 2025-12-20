import 'package:flutter/material.dart';
import 'package:untitled2/inventory/screens/category_settings_screen.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';
import 'settings_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});
  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  // --- All state variables and functions MUST be declared inside the State class ---
  
  final List<Map<String, dynamic>> _menuItems = [
    {'id': '1', 'name': 'Classic Burger', 'price': 899.00, 'category': 'Main Course', 'isAvailable': true, 'isVegetarian': false},
    {'id': '2', 'name': 'French Fries', 'price': 249.00, 'category': 'Sides', 'isAvailable': true, 'isVegetarian': true},
    {'id': '3', 'name': 'Chocolate Lava Cake', 'price': 350.00, 'category': 'Dessert', 'isAvailable': false, 'isVegetarian': true},
    {'id': '4', 'name': 'Caesar Salad', 'price': 450.00, 'category': 'Appetizer', 'isAvailable': true, 'isVegetarian': false},
    {'id': '5', 'name': 'Paneer Tikka Pizza', 'price': 799.00, 'category': 'Main Course', 'isAvailable': true, 'isVegetarian': true},
    {'id': '6', 'name': 'Espresso', 'price': 199.00, 'category': 'Beverages', 'isAvailable': false, 'isVegetarian': true},
    {'id': '7', 'name': 'Nachos Grande', 'price': 550.00, 'category': 'Appetizer', 'isAvailable': true, 'isVegetarian': true},
  ];
  
  // This list now correctly lives inside the State class
  final List<String> _allCategories = ['Appetizer', 'Main Course', 'Sides', 'Dessert', 'Beverages', 'Curry'];

  String _selectedCategory = 'All';
  bool _showVegOnly = false;
  
  // This helper function also correctly lives inside the State class
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

  // 3. KEPT your existing navigation logic.
  void _navigateToAddItemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const AddItemScreen()),
    );
  }

  void _navigateToEditItemScreen(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => EditItemScreen(item: item)),
    );
  }

  void _navigateToCategorySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const CategorySettingsScreen()),
    );
  }
  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
    );
  }

    @override
  Widget build(BuildContext context) {
    // --- DATA PROCESSING AND FILTERING ---
    List<Map<String, dynamic>> visibleItems = _menuItems;
    if (_showVegOnly) {
      visibleItems = visibleItems.where((item) => item['isVegetarian'] == true).toList();
    }
    
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in visibleItems) {
      final category = item['category'];
      if (groupedItems[category] == null) { groupedItems[category] = []; }
      groupedItems[category]!.add(item);
    }
    
    final List<String> categoriesToShow = _selectedCategory == 'All'
        ? (_allCategories..sort())
        : [_selectedCategory];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _navigateToSettings, // Now correctly defined
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ['All', ...(_allCategories..sort())].length, // Now correctly defined
                  itemBuilder: (context, index) {
                    final category = ['All', ...(_allCategories..sort())][index]; // Now correctly defined
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                        selected: category == _selectedCategory,
                        onSelected: (selected) => setState(() => _selectedCategory = category),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: categoriesToShow.length,
                  itemBuilder: (context, index) {
                    final category = categoriesToShow[index];
                    final itemsInCategory = groupedItems[category] ?? [];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(category, style: Theme.of(context).textTheme.headlineSmall),
                        ),
                        if (itemsInCategory.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: Text('No items in this category.')),
                          )
                        else
                          ...itemsInCategory.map((item) => _buildMenuItemCard(item)).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => setState(() => _showVegOnly = !_showVegOnly),
                  icon: Icon(Icons.eco, color: _showVegOnly ? Colors.white : Colors.green),
                  label: Text('Veg Only', style: TextStyle(color: _showVegOnly ? Colors.white : Colors.black)),
                  backgroundColor: _showVegOnly ? Colors.green : Colors.white,
                  heroTag: 'vegToggle',
                ),
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
  
  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _navigateToEditItemScreen(item),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(_getCategoryIcon(item['category']), color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(item['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('₹${item['price'].toStringAsFixed(2)}'),
        trailing: Switch(
          value: item['isAvailable'],
          onChanged: (bool value) {
            setState(() {
              final originalIndex = _menuItems.indexWhere((i) => i['id'] == item['id']);
              if (originalIndex != -1) {
                _menuItems[originalIndex]['isAvailable'] = value;
              }
            });
          },
        ),
      ),
    );
  }
}