   // lib/screens/product/add_product_screen.dart
   import 'package:flutter/material.dart';
   import '../../models/product.dart';
   import '../../services/database_service.dart';
   import 'package:provider/provider.dart';
   import '../../services/auth_service.dart';
   import '../../widgets/custom_button.dart';

   class AddProductScreen extends StatefulWidget {
     @override
     _AddProductScreenState createState() => _AddProductScreenState();
   }

   class _AddProductScreenState extends State<AddProductScreen> {
     final _formKey = GlobalKey<FormState>();
     final _titleController = TextEditingController();
     final _descriptionController = TextEditingController();
     final _priceController = TextEditingController();
     final _imageUrlController = TextEditingController();
     bool _isLoading = false;
     String? _errorMessage;

     @override
     void dispose() {
       _titleController.dispose();
       _descriptionController.dispose();
       _priceController.dispose();
       _imageUrlController.dispose();
       super.dispose();
     }

     Future<void> _submitProduct() async {
       if (!_formKey.currentState!.validate()) return;

       setState(() {
         _isLoading = true;
         _errorMessage = null;
       });

       try {
         final authService = Provider.of<AuthService>(context, listen: false);
         final currentUser = authService.currentUser;
         
         if (currentUser == null) {
           throw Exception('You must be logged in to add a product');
         }

         final product = Product(
           id: '', // This will be set by Firestore
           title: _titleController.text.trim(),
           description: _descriptionController.text.trim(),
           price: double.parse(_priceController.text),
           imageUrl: _imageUrlController.text.trim(),
           sellerId: currentUser.uid,
           sellerName: currentUser.displayName ?? 'Unknown Seller',
           createdAt: DateTime.now(),
         );

         final databaseService = DatabaseService();
         await databaseService.addProduct(product);

         if (mounted) {
           Navigator.pop(context);
         }
       } catch (e) {
         setState(() {
           _errorMessage = e.toString();
         });
       } finally {
         if (mounted) {
           setState(() {
             _isLoading = false;
           });
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
                     prefixText: '\$',
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
                   controller: _imageUrlController,
                   decoration: InputDecoration(
                     labelText: 'Image URL',
                     border: OutlineInputBorder(),
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter an image URL';
                     }
                     final uri = Uri.tryParse(value);
                     if (uri == null || !uri.isAbsolute) {
                       return 'Please enter a valid URL';
                     }
                     return null;
                   },
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