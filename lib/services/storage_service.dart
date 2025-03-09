import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File imageFile, String userId) async {
    try {
      print('StorageService: Starting image upload...');
      
      // Create a unique file name using timestamp
      String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      print('StorageService: Generated filename: $fileName');
      
      // Create the file reference
      Reference ref = _storage.ref().child('products/$userId/$fileName');
      print('StorageService: Created storage reference');

      // Set metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/${path.extension(imageFile.path).replaceAll('.', '')}',
        customMetadata: {'userId': userId},
      );
      print('StorageService: Created metadata');

      // Upload the file with metadata
      print('StorageService: Starting upload task...');
      await ref.putFile(
        imageFile,
        metadata,
      ).whenComplete(() => print('StorageService: Upload completed'));

      // Get the download URL
      print('StorageService: Getting download URL...');
      String downloadUrl = await ref.getDownloadURL();
      print('StorageService: Got download URL: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('StorageService Error: $e');
      print('StorageService Stack trace: $stackTrace');
      
      if (e is FirebaseException) {
        if (e.code == 'unauthorized') {
          throw Exception('Not authorized to upload images. Please check your authentication.');
        } else if (e.code == 'canceled') {
          throw Exception('Upload was canceled.');
        } else if (e.code == 'storage/unknown') {
          throw Exception('Unknown error occurred during upload. Please try again.');
        }
      }
      
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      
      // Create reference from the URL
      Reference ref = _storage.refFromURL(imageUrl);
      
      // Delete the file
      await ref.delete();
      print('StorageService: Image deleted successfully');
    } catch (e) {
      print('StorageService: Error deleting image: $e');
      // Don't throw here as this is a cleanup operation
    }
  }
} 