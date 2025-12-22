class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // e.g., 'Appetizers', 'Main Course', 'Desserts'
  final String imageUrl; // URL for the dish's image
  final bool isAvailable; // To quickly mark as "Sold Out"
  final List<String> dietaryTags; // e.g., ['Vegetarian', 'Gluten-Free']

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.dietaryTags = const [],
  });
}