// lib/screens/menu/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import '../product/product_detail_screen.dart';
import '../messaging/conversations_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../product/add_product_screen.dart';
import '../../utils/gradients.dart'; // Import the gradients utility
import '../auth/login_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final List<String> _categories = [
    'All', 'Textbooks', 'Electronics', 'Furniture', 'Housing', 'Other'
  ];
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Campus Trade',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              'Find what you need',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () async {
                              await Provider.of<AuthService>(context, listen: false).signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Categories
                    Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category == _selectedCategory;
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = category),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Products Grid
            StreamBuilder<List<Product>>(
              stream: _databaseService.productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final products = snapshot.data ?? [];
                final filteredProducts = _selectedCategory == 'All'
                    ? products
                    : products.where((p) => p.category == _selectedCategory).toList();

                if (filteredProducts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No items available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product);
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add_product');
        },
        icon: Icon(Icons.add),
        label: Text('List Item'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: product.isSold
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Text(
                            'SOLD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            // Product Info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.location ?? 'On Campus',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}