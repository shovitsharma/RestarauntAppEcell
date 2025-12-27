import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/inventory/models/category.dart';
import 'package:untitled2/inventory/models/inventory_item_model.dart';

class InventoryService {
  // References to collections
  final CollectionReference _menuCollection =
      FirebaseFirestore.instance.collection('menu_items');
  final CollectionReference _categoryCollection =
      FirebaseFirestore.instance.collection('categories');

  // --- CREATE ---

  Future<void> addCategory(String name) async {
    try {
      // 1. Check for duplicates (Add timeout of 5 seconds)
      final query = await _categoryCollection
          .where('name', isEqualTo: name)
          .get()
          .timeout(const Duration(seconds: 5)); // <--- ADD THIS

      if (query.docs.isNotEmpty) {
        throw Exception('Category already exists');
      }

      // 2. Add the category (Add timeout of 5 seconds)
      await _categoryCollection
          .add({'name': name})
          .timeout(const Duration(seconds: 5)); // <--- ADD THIS
          
    } catch (e) {
      throw e;
    }
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    try {
      // correctly converts the object to a Map before sending
      await _menuCollection.add(item.toMap()); 
    } catch (e) {
      print('Error adding item: $e');
      throw e;
    }
  }
  Future<bool> isCategoryInUse(String categoryName) async {
    try {
      // We limit(1) because we only need to know if ONE exists
      final snapshot = await _menuCollection
          .where('category', isEqualTo: categoryName)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking category usage: $e');
      return true; // Fail safe: assume it is in use if error occurs
    }
  }

  // --- READ ---

  // 1. Get ALL items (Required by your InventoryListScreen)
  Stream<List<MenuItemModel>> getMenuItems() {
    return _menuCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MenuItemModel.fromSnapshot(doc);
      }).toList();
    });
  }

  // 2. Get Categories
  Stream<List<CategoryModel>> getCategories() {
    return _categoryCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromSnapshot(doc);
      }).toList();
    });
  }

  // 3. Get items by specific category
  Stream<List<MenuItemModel>> getItemsByCategory(String category) {
    return _menuCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromSnapshot(doc))
            .toList());
  }

  // --- UPDATE ---

  Future<void> updateMenuItem(MenuItemModel item) async {
    try {
      await _menuCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      print('Error updating item: $e');
      throw e;
    }
  }

  Future<void> updateAvailability(String itemId, bool isAvailable) async {
    try {
      await _menuCollection.doc(itemId).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      print('Error updating availability: $e');
      throw e;
    }
  }

  // --- DELETE ---
  Future<void> deleteMenuItem(String id) async {
    try {
      // Deletes the document with the specific ID from the 'menu_items' collection
      await _menuCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting item: $e');
      throw e;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryCollection.doc(id).delete();
    } catch (e) {
      throw e;
    }
  }
}