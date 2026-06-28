class Product {
  final String id;
  final String name;
  final double price;
  final String category; // Dresses, Tops, Bottoms, Accessories
  final String imageUrl; // network url, asset path, or data uri
  final String instagramUrl; // hyperlink to buy / IG post
  final bool favorite; // featured in "Shop Our Favorites"

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.instagramUrl = '',
    this.favorite = true,
  });

  Product copyWith({
    String? name,
    double? price,
    String? category,
    String? imageUrl,
    String? instagramUrl,
    bool? favorite,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        instagramUrl: instagramUrl ?? this.instagramUrl,
        favorite: favorite ?? this.favorite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'imageUrl': imageUrl,
        'instagramUrl': instagramUrl,
        'favorite': favorite,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        price: (j['price'] as num).toDouble(),
        category: j['category'] as String? ?? 'Dresses',
        imageUrl: j['imageUrl'] as String? ?? '',
        instagramUrl: j['instagramUrl'] as String? ?? '',
        favorite: j['favorite'] as bool? ?? true,
      );
}
