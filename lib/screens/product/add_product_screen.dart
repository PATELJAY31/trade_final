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

   class AddProductScreen extends StatefulWidget {
     @override
     _AddProductScreenState createState() => _AddProductScreenState();
   }

   class _AddProductScreenState extends State<AddProductScreen> {
     final _formKey = GlobalKey<FormState>();
     final _titleController = TextEditingController();
     final _descriptionController = TextEditingController();
     final _priceController = TextEditingController();
     bool _isLoading = false;
     String? _errorMessage;
     File? _selectedImage;
     final _imagePicker = ImagePicker();
     final _storageService = StorageService();

     @override
     void dispose() {
       _titleController.dispose();
       _descriptionController.dispose();
       _priceController.dispose();
       super.dispose();
     }

     Future<void> _pickImage() async {
       try {
         // Reset any previous error message
         setState(() {
           _errorMessage = null;
         });

         // Show image source selection dialog
         final ImageSource? source = await showDialog<ImageSource>(
           context: context,
           builder: (BuildContext context) => AlertDialog(
             title: Text('Select Image Source'),
             content: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 ListTile(
                   leading: Icon(Icons.photo_library),
                   title: Text('Gallery'),
                   onTap: () => Navigator.pop(context, ImageSource.gallery),
                 ),
                 ListTile(
                   leading: Icon(Icons.camera_alt),
                   title: Text('Camera'),
                   onTap: () => Navigator.pop(context, ImageSource.camera),
                 ),
               ],
             ),
           ),
         );

         if (source == null) return;

         // Request permission and pick image
         final XFile? pickedFile = await _imagePicker.pickImage(
           source: source,
           maxWidth: 1024,
           maxHeight: 1024,
           imageQuality: 85,
           requestFullMetadata: false,
         ).timeout(
           Duration(seconds: 30),
           onTimeout: () {
             throw Exception('Image picking timed out. Please try again.');
           },
         );

         if (pickedFile != null) {
           setState(() {
             _selectedImage = File(pickedFile.path);
           });
         }
       } on PlatformException catch (e) {
         print('Platform Exception during image pick: $e');
         String errorMessage = 'Failed to pick image';
         
         if (e.code == 'photo_access_denied') {
           errorMessage = 'Please grant photo access permission in your device settings';
         } else if (e.code == 'camera_access_denied') {
           errorMessage = 'Please grant camera access permission in your device settings';
         } else if (e.code == 'channel-error') {
           // Retry the operation after a short delay
           await Future.delayed(Duration(milliseconds: 500));
           try {
             final XFile? pickedFile = await _imagePicker.pickImage(
               source: ImageSource.gallery,
               maxWidth: 1024,
               maxHeight: 1024,
               imageQuality: 85,
               requestFullMetadata: false,
             );
             
             if (pickedFile != null) {
               setState(() {
                 _selectedImage = File(pickedFile.path);
               });
               return;
             }
           } catch (retryError) {
             print('Retry failed: $retryError');
             errorMessage = 'Please try again or choose a different image';
           }
         }

         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(errorMessage),
               duration: Duration(seconds: 3),
               action: SnackBarAction(
                 label: 'Settings',
                 onPressed: () {
                   // You can add logic here to open app settings
                   // This requires another package like 'app_settings'
                 },
               ),
             ),
           );
         }
       } catch (e) {
         print('Error picking image: $e');
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('An error occurred while picking the image. Please try again.'),
               duration: Duration(seconds: 3),
             ),
           );
         }
       }
     }

     Future<void> _submitProduct() async {
       if (!_formKey.currentState!.validate()) return;
       if (_selectedImage == null) {
         setState(() {
           _errorMessage = 'Please select an image';
         });
         return;
       }

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

         // Upload image first
         final imageUrl = await _storageService.uploadProductImage(_selectedImage!, currentUser.uid);

         final product = Product(
           id: '', // This will be set by Firestore
           title: _titleController.text.trim(),
           description: _descriptionController.text.trim(),
           price: double.parse(_priceController.text),
           imageUrl: imageUrl,
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
                 // Image picker section
                 GestureDetector(
                   onTap: _pickImage,
                   child: Container(
                     height: 200,
                     decoration: BoxDecoration(
                       color: Colors.grey[200],
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.grey[300]!),
                     ),
                     child: _selectedImage != null
                         ? ClipRRect(
                             borderRadius: BorderRadius.circular(12),
                             child: Image.file(
                               _selectedImage!,
                               fit: BoxFit.cover,
                               width: double.infinity,
                             ),
                           )
                         : Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.add_photo_alternate,
                                 size: 48,
                                 color: Colors.grey[400],
                               ),
                               SizedBox(height: 8),
                               Text(
                                 'Tap to add product image',
                                 style: TextStyle(
                                   color: Colors.grey[600],
                                 ),
                               ),
                             ],
                           ),
                   ),
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