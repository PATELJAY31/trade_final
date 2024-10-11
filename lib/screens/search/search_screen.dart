// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/messaging_service.dart';
import '../../services/database_service.dart';
import '../messaging/messaging_screen.dart';
import '../product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/gradients.dart'; // Import the gradients utility

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
      // Make the AppBar transparent to blend with the gradient
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Search Products'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient, // Apply the background gradient
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Card(
              color: Colors.white.withOpacity(0.85), // Semi-transparent card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: _search,
                      ),
                    ),
                    // Product List
                    query.isEmpty
                        ? Center(
                            child: Text(
                              'Enter a query to search for products.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          )
                        : filteredProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'No products found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 4.0,
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: product.imageUrl.isNotEmpty
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
                                      ),
                                      title: Text(
                                        product.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                      trailing: Icon(Icons.arrow_forward),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailScreen(product: product),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
