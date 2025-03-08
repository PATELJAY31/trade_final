import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File imageFile, String userId) async {
    try {
      // Create a unique file name using timestamp
      String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Create the file reference
      Reference ref = _storage.ref().child('products/$userId/$fileName');
      
      // Upload the file
      await ref.putFile(imageFile);
      
      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      
      // Create reference from the URL
      Reference ref = _storage.refFromURL(imageUrl);
      
      // Delete the file
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw here as this is a cleanup operation
    }
  }
} 