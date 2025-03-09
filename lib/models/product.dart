import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final bool isSold;
  final DateTime createdAt;
  final String category;
  final String? location;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    this.isSold = false,
    required this.createdAt,
    required this.category,
    this.location,
  });

  // Convert Firestore document to Product object
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      isSold: data['isSold'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'Others',
      location: data['location'],
    );
  }

  // Convert Product object to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'isSold': isSold,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'location': location,
    };
  }

  // Optional: Implement copyWith if needed
  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    bool? isSold,
    DateTime? createdAt,
    String? category,
    String? location,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      isSold: isSold ?? this.isSold,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      location: location ?? this.location,
    );
  }
}