   // lib/screens/product/add_product_screen.dart
   import 'package:flutter/material.dart';
   import '../../models/product.dart';
   import '../../services/database_service.dart';
   import 'package:provider/provider.dart';
   import '../../services/auth_service.dart';

   class AddProductScreen extends StatefulWidget {
     @override
     _AddProductScreenState createState() => _AddProductScreenState();
   }

   class _AddProductScreenState extends State<AddProductScreen> {
     final _formKey = GlobalKey<FormState>();
     String title = '';
     String description = '';
     double price = 0.0;
     String imageUrl = '';
     bool isLoading = false;

     void _addProduct() async {
       if (_formKey.currentState!.validate()) {
         setState(() {
           isLoading = true;
         });
         try {
           final authService = Provider.of<AuthService>(context, listen: false);
           final currentUser = authService.currentUser;
           if (currentUser == null) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('You must be logged in to add a product.')),
             );
             return;
           }

           Product newProduct = Product(
             id: '', // Firestore will generate ID
             title: title,
             description: description,
             price: price,
             imageUrl: imageUrl,
             sellerId: currentUser.uid,
             isSold: false,
             buyerId: '',
           );

           await DatabaseService().addOrUpdateProduct(newProduct);
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Product Added')),
           );
           Navigator.of(context).pop();
         } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Failed to add product: $e')),
           );
         } finally {
           setState(() {
             isLoading = false;
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
         body: Padding(
           padding: EdgeInsets.all(16.0),
           child: Form(
             key: _formKey,
             child: SingleChildScrollView(
               child: Column(
                 children: [
                   // Title Field
                   TextFormField(
                     decoration: InputDecoration(labelText: 'Title'),
                     validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                     onChanged: (value) => setState(() { title = value; }),
                   ),
                   SizedBox(height: 16),
                   // Description Field
                   TextFormField(
                     decoration: InputDecoration(labelText: 'Description'),
                     validator: (value) => value == null || value.isEmpty ? 'Enter a description' : null,
                     onChanged: (value) => setState(() { description = value; }),
                     maxLines: 3,
                   ),
                   SizedBox(height: 16),
                   // Price Field
                   TextFormField(
                     decoration: InputDecoration(labelText: 'Price'),
                     validator: (value) {
                       if (value == null || value.isEmpty) return 'Enter a price';
                       if (double.tryParse(value) == null) return 'Enter a valid number';
                       return null;
                     },
                     onChanged: (value) => setState(() { price = double.parse(value); }),
                     keyboardType: TextInputType.number,
                   ),
                   SizedBox(height: 16),
                   // Image URL Field
                   TextFormField(
                     decoration: InputDecoration(labelText: 'Image URL'),
                     onChanged: (value) => setState(() { imageUrl = value; }),
                   ),
                   SizedBox(height: 32),
                   // Submit Button
                   ElevatedButton(
                     onPressed: isLoading ? null : _addProduct,
                     child: isLoading
                         ? CircularProgressIndicator(
                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                           )
                         : Text('Add Product'),
                     style: ElevatedButton.styleFrom(
                       minimumSize: Size(double.infinity, 50),
                     ),
                   ),
                 ],
               ),
             ),
           ),
         ),
       );
     }
   }