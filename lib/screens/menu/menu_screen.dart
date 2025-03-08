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
  int _currentIndex = 0;
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: StreamBuilder<List<Product>>(
          stream: _databaseService.productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No products available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final currentUser = authService.currentUser;
                  bool isSeller = product.sellerId == currentUser?.uid;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/default_product.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                if (product.isSold)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'SOLD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isSeller || product.isSold
                                        ? null
                                        : () => _buyProduct(product),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSeller
                                          ? Colors.grey
                                          : product.isSold
                                              ? Colors.red
                                              : Colors.blue,
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      isSeller
                                          ? 'Your Product'
                                          : product.isSold
                                              ? 'Sold'
                                              : 'Buy Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _buyProduct(Product product) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to buy products')),
        );
        return;
      }

      await _databaseService.markProductAsSold(product.id, authService.currentUser!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product purchased successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase product: ${e.toString()}')),
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        // Home Tab - Already in Home, no action needed
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConversationsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      default:
        break;
    }
  }
}