   // lib/screens/product/add_product_screen.dart
   import 'dart:io';
   import 'package:flutter/material.dart';
   import 'package:flutter/services.dart';
   import 'package:image_picker/image_picker.dart';
   import '../../models/product.dart';
   import '../../services/database_service.dart';
   import '../../services/storage_service.dart';
   import 'package:provider/provider.dart';
   import '../../services/auth_service.dart';
   import '../../widgets/custom_button.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';

   class AddProductScreen extends StatefulWidget {
     @override
     _AddProductScreenState createState() => _AddProductScreenState();
   }

   class _AddProductScreenState extends State<AddProductScreen> {
     final _formKey = GlobalKey<FormState>();
     final _titleController = TextEditingController();
     final _descriptionController = TextEditingController();
     final _priceController = TextEditingController();
     final _locationController = TextEditingController();
     final _imageUrlController = TextEditingController();  // New controller for image URL
     String _selectedCategory = 'Others';
     bool _isLoading = false;
     String? _errorMessage;

     final List<String> _categories = [
       'Textbooks',
       'Electronics',
       'Furniture',
       'Housing',
       'Sports',
       'Others',
     ];

     @override
     void dispose() {
       _titleController.dispose();
       _descriptionController.dispose();
       _priceController.dispose();
       _locationController.dispose();
       _imageUrlController.dispose();  // Dispose the new controller
       super.dispose();
     }

     Future<void> _submitProduct() async {
       print('Starting product submission...');
       if (!_formKey.currentState!.validate()) {
         print('Form validation failed');
         return;
       }

       setState(() {
         _isLoading = true;
         _errorMessage = null;
       });
       print('Set loading state to true');

       try {
         // Validate price format
         final price = double.tryParse(_priceController.text.trim());
         if (price == null || price < 0) {
           throw Exception('Please enter a valid price');
         }

         print('Getting current user...');
         final authService = Provider.of<AuthService>(context, listen: false);
         final currentUser = authService.currentUser;
         
         if (currentUser == null) {
           throw Exception('You must be logged in to add a product');
         }
         print('Current user found: ${currentUser.uid}');

         // Validate required fields
         final title = _titleController.text.trim();
         final description = _descriptionController.text.trim();
         final location = _locationController.text.trim();
         final imageUrl = _imageUrlController.text.trim();

         if (title.isEmpty) {
           throw Exception('Title cannot be empty');
         }

         if (description.isEmpty) {
           throw Exception('Description cannot be empty');
         }

         // Create product with validated data
         final product = Product(
           id: '', // This will be set by Firestore
           title: title,
           description: description,
           price: price,
           imageUrl: imageUrl,  // Will use default if empty
           sellerId: currentUser.uid,
           sellerName: currentUser.displayName ?? 'Unknown Seller',
           createdAt: DateTime.now(),
           category: _selectedCategory,
           location: location,
         );
         print('Product object created: ${product.toFirestore()}');

         print('Adding product to database...');
         final databaseService = DatabaseService();
         
         // Check if database service is initialized
         if (databaseService == null) {
           throw Exception('Database service not initialized');
         }

         final productId = await databaseService.addProduct(product);
         
         if (productId == null || productId.isEmpty) {
           throw Exception('Failed to get product ID from database');
         }
         
         print('Product added successfully with ID: $productId');

         if (mounted) {
           setState(() {
             _isLoading = false;
           });
           print('Reset loading state to false');

           // Show success dialog
           await showDialog(
             context: context,
             barrierDismissible: false,
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Row(
                   children: [
                     Icon(Icons.check_circle, color: Colors.green),
                     SizedBox(width: 8),
                     Text('Success'),
                   ],
                 ),
                 content: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Product added successfully!'),
                     SizedBox(height: 8),
                     Text(
                       'Product ID: $productId',
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.grey,
                       ),
                     ),
                   ],
                 ),
                 actions: [
                   TextButton(
                     onPressed: () {
                       // Clear form fields
                       _titleController.clear();
                       _descriptionController.clear();
                       _priceController.clear();
                       _locationController.clear();
                       _imageUrlController.clear();
                       setState(() {
                         _selectedCategory = 'Others';
                       });
                       Navigator.of(context).pop(); // Close dialog
                       Navigator.of(context).pop(); // Return to previous screen
                     },
                     child: Text('Done'),
                   ),
                   TextButton(
                     onPressed: () {
                       // Clear form fields
                       _titleController.clear();
                       _descriptionController.clear();
                       _priceController.clear();
                       _locationController.clear();
                       _imageUrlController.clear();
                       setState(() {
                         _selectedCategory = 'Others';
                       });
                       Navigator.of(context).pop(); // Close dialog only
                     },
                     child: Text('Add Another'),
                   ),
                 ],
               );
             },
           );
         }
       } catch (e) {
         print('Error in _submitProduct: $e');
         if (mounted) {
           setState(() {
             _isLoading = false;
             _errorMessage = e.toString().replaceAll('Exception: ', '');
           });

           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(
                 'Error: ${_errorMessage}',
                 style: TextStyle(color: Colors.white),
               ),
               backgroundColor: Colors.red,
               duration: Duration(seconds: 3),
               action: SnackBarAction(
                 label: 'Dismiss',
                 textColor: Colors.white,
                 onPressed: () {
                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                 },
               ),
             ),
           );
         }
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('Add Product'),
         ),
         body: SingleChildScrollView(
           padding: EdgeInsets.all(16.0),
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 if (_errorMessage != null)
                   Padding(
                     padding: EdgeInsets.only(bottom: 16.0),
                     child: Text(
                       _errorMessage!,
                       style: TextStyle(color: Colors.red),
                     ),
                   ),
                 // Image URL input field
                 TextFormField(
                   controller: _imageUrlController,
                   decoration: InputDecoration(
                     labelText: 'Image URL (Optional)',
                     hintText: 'Enter image URL or leave empty for default image',
                     border: OutlineInputBorder(),
                     prefixIcon: Icon(Icons.image),
                   ),
                   keyboardType: TextInputType.url,
                   validator: (value) {
                     if (value != null && value.isNotEmpty) {
                       final uri = Uri.tryParse(value);
                       if (uri == null || !uri.hasAbsolutePath) {
                         return 'Please enter a valid URL';
                       }
                     }
                     return null;
                   },
                 ),
                 SizedBox(height: 16.0),
                 // Category Dropdown
                 DropdownButtonFormField<String>(
                   value: _selectedCategory,
                   decoration: InputDecoration(
                     labelText: 'Category',
                     border: OutlineInputBorder(),
                   ),
                   items: _categories.map((String category) {
                     return DropdownMenuItem(
                       value: category,
                       child: Text(category),
                     );
                   }).toList(),
                   onChanged: (String? newValue) {
                     if (newValue != null) {
                       setState(() {
                         _selectedCategory = newValue;
                       });
                     }
                   },
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please select a category';
                     }
                     return null;
                   },
                 ),
                 SizedBox(height: 16.0),
                 TextFormField(
                   controller: _titleController,
                   decoration: InputDecoration(
                     labelText: 'Title',
                     border: OutlineInputBorder(),
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter a title';
                     }
                     return null;
                   },
                 ),
                 SizedBox(height: 16.0),
                 TextFormField(
                   controller: _descriptionController,
                   decoration: InputDecoration(
                     labelText: 'Description',
                     border: OutlineInputBorder(),
                   ),
                   maxLines: 3,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter a description';
                     }
                     return null;
                   },
                 ),
                 SizedBox(height: 16.0),
                 TextFormField(
                   controller: _priceController,
                   decoration: InputDecoration(
                     labelText: 'Price',
                     border: OutlineInputBorder(),
                     prefixText: '₹',
                   ),
                   keyboardType: TextInputType.numberWithOptions(decimal: true),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter a price';
                     }
                     if (double.tryParse(value) == null) {
                       return 'Please enter a valid number';
                     }
                     return null;
                   },
                 ),
                 SizedBox(height: 16.0),
                 TextFormField(
                   controller: _locationController,
                   decoration: InputDecoration(
                     labelText: 'Location (Optional)',
                     border: OutlineInputBorder(),
                     prefixIcon: Icon(Icons.location_on_outlined),
                   ),
                 ),
                 SizedBox(height: 24.0),
                 CustomButton(
                   text: _isLoading ? 'Adding Product...' : 'Add Product',
                   onPressed: _isLoading ? null : _submitProduct,
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }