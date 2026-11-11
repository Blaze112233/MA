class Product {
  final int id;
  final int categoryId;
  final String name;
  final String brand;
  final String description;
  final double price;
  final int stockQuantity;
  final double rating;
  final String? imageUrl;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.rating,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.parse(json['category_id']?.toString() ?? '0'),
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      stockQuantity: json['stock_quantity'] != null
          ? int.parse(json['stock_quantity'].toString())
          : 0,
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 5.0,
      imageUrl: json['image_url']?.toString(),
    );
  }
}