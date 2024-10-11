// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/messaging_service.dart';
import '../../services/database_service.dart';
import '../messaging/messaging_screen.dart';
import '../product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<Product> filteredProducts = [];
  final MessagingService _messagingService = MessagingService();
  final DatabaseService _databaseService = DatabaseService();

  void _search(String input) async {
    if (input.isEmpty) {
      setState(() {
        query = '';
        filteredProducts = [];
      });
      return;
    }
    List<Product> results = await _databaseService.searchProducts(input);
    setState(() {
      query = input;
      filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final products = query.isEmpty ? [] : filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Products'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.blueAccent, // Enhanced icon color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _search,
            ),
          ),
          // Product List
          Expanded(
            child: query.isEmpty
                ? Center(child: Text('Enter a query to search for'))
                : filteredProducts.isEmpty
                    ? Center(child: Text('No products found.'))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ListTile(
                            leading: product.imageUrl.isNotEmpty
                                ? Image.network(
                                    product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/default_product.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                            title: Text(product.title),
                            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}