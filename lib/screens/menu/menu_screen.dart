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

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    List<Product> products = await _databaseService.getAllProducts();
    setState(() {
      _products = products;
    });
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

  void _buyNow(BuildContext context, Product product) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final DatabaseService databaseService = DatabaseService();

    print('Current User: ${currentUser?.uid}'); // Debugging line

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

    try {
      // Implement your buy logic here
      // For example, updating the product's isSold status in Firestore
      await databaseService.buyProduct(product.id, currentUser.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase successful!')),
      );

      _fetchProducts(); // Refresh the product list
    } catch (e) {
      print('Buy Now Error: $e'); // Debugging line
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase the product.')),
      );
    }
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: _products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final product = _products[index];
          final authService = Provider.of<AuthService>(context, listen: false);
          final currentUser = authService.currentUser;

          // Determine if the current user is the seller
          bool isSeller = product.sellerId == currentUser?.uid;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              ).then((_) => _fetchProducts()); // Refresh after returning
            },
            child: Stack(
              children: [
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Product Image
                      Expanded(
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.asset(
                                'assets/images/default_product.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                      SizedBox(height: 8),
                      // Product Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Product Price
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Buy Now Button
                      isSeller
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Sellers cannot buy their own products
                                },
                                child: Text('Your Product'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 36),
                                  backgroundColor: Colors.grey, // Updated from 'primary'
                                ),
                                
                              ),
                            )
                          : product.isSold
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: null, // Disable button
                                    child: Text('Sold'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 36),
                                      backgroundColor: Colors.redAccent, // Updated from 'primary'
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () => _buyNow(context, product),
                                    child: Text('Buy Now'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 36),
                                      backgroundColor: Colors.redAccent, // Updated from 'primary'
                                    ),
                                  ),
                                ),
                    ],
                  ),
                ),
                if (product.isSold)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          'SOLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('College Buy & Sell'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await Provider.of<AuthService>(context, listen: false).signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ),
        ],
      ),
      body: _buildProductGrid(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to AddProductScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          ).then((_) => _fetchProducts()); // Refresh after adding
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed, // Ensure fixed type for visibility
        selectedItemColor: Colors.blueAccent, // Set to desired color
        unselectedItemColor: Colors.grey, // Set to desired color
        backgroundColor: Colors.white, // Set to desired background color
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
}