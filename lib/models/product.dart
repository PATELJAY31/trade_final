import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerId;
  final bool isSold;
  final String? buyerId;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    this.isSold = false,
    this.buyerId,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      isSold: data['isSold'] ?? false,
      buyerId: data['buyerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'isSold': isSold,
      'buyerId': buyerId,
      'lastUpdated': FieldValue.serverTimestamp(),
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
    bool? isSold,
    String? buyerId,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      isSold: isSold ?? this.isSold,
      buyerId: buyerId ?? this.buyerId,
    );
  }
}