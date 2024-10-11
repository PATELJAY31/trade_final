// lib/screens/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    bool isSeller = product.sellerId == currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          if (isSeller)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Delete Product'),
                    content: Text('Are you sure you want to delete this product?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ],
                  ),
                );
                if (confirm) {
                  // Delete the product
                  await DatabaseService().deleteProduct(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product deleted')),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/default_product.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
              SizedBox(height: 20),
              Text(
                product.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              if (!product.isSold)
                ElevatedButton(
                  onPressed: () => _buyNow(context, product),
                  child: Text('Buy Now'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                )
              else
                Text(
                  'This product has been sold.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _buyNow(BuildContext context, Product product) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final DatabaseService databaseService = DatabaseService();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to buy a product.')),
      );
      return;
    }

    if (product.sellerId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot buy your own product.')),
      );
      return;
    }

    // Implement your buy logic here
    // For example, updating the product's isSold status in Firestore
    await databaseService.buyProduct(product.id, currentUser.uid);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase successful!')),
    );

    // Navigate back or refresh
    Navigator.of(context).pop();
  }
}