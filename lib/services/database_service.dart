import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users Collection Reference
  CollectionReference get usersRef => _db.collection('users');

  // Products Collection Reference
  CollectionReference get productsRef => _db.collection('products');

  // Messages Collection Reference
  CollectionReference get messagesRef => _db.collection('messages');

  // Reference to conversations collection
  final CollectionReference conversationsRef = FirebaseFirestore.instance.collection('conversations');

  // Create a new user
  Future<void> createUser(UserModel user) async {
    await usersRef.doc(user.uid).set(user.toMap());
  }

  // Check if a user exists
  Future<bool> checkUserExists(String uid) async {
    DocumentSnapshot doc = await usersRef.doc(uid).get();
    return doc.exists;
  }

  // Get user data
  Future<UserModel> getUser(String uid) async {
    DocumentSnapshot doc = await usersRef.doc(uid).get();
    return UserModel.fromDocument(doc);
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    await usersRef.doc(user.uid).update(user.toMap());
  }

  // Add or update a product
  Future<void> addOrUpdateProduct(Product product) async {
    if (product.id.isEmpty) {
      await productsRef.add(product.toMap());
    } else {
      await productsRef.doc(product.id).update(product.toMap());
    }
  }

  // Search products by query with error handling
  Future<List<Product>> searchProducts(String query) async {
    try {
      QuerySnapshot snapshot = await productsRef
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
    } catch (e) {
      print('DatabaseService: Failed to search products: $e');
      return [];
    }
  }

  // Filter products
  Future<List<Product>> filterProducts({
    double? minPrice,
    double? maxPrice,
    String? category, // Assuming you have a category field
  }) async {
    Query query = productsRef;

    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    try {
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
    } catch (e) {
      print('DatabaseService: Failed to filter products: $e');
      return [];
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await productsRef.get();
      return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
    } catch (e) {
      print('DatabaseService: Failed to fetch products: $e');
      return [];
    }
  }

  // Buy a product
  Future<void> buyProduct(String productId, String buyerId) async {
    try {
      DocumentReference productRef = productsRef.doc(productId);
      DocumentSnapshot productSnapshot = await productRef.get();

      if (!productSnapshot.exists) {
        throw Exception('Product does not exist.');
      }

      Product product = Product.fromDocument(productSnapshot);

      if (product.isSold) {
        throw Exception('Product is already sold.');
      }

      // Update the product's status to sold and record the buyer
      await productRef.update({
        'isSold': true,
        'buyerId': buyerId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('DatabaseService: Failed to buy product: $e');
      throw e;
    }
  }

  // Send a message
  Future<void> sendMessage(
      String chatId, String content, String senderId, String receiverId) async {
    await conversationsRef.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the conversation document with the last message and timestamp
    await conversationsRef.doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastMessage': content,
      'receiverId': receiverId,
      'receiverName': 'Receiver Name', // Replace with actual receiver name
      'receiverAvatarUrl':
          'https://example.com/avatar.png', // Replace with actual avatar URL
    }, SetOptions(merge: true));
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String chatId, String currentUserId) {
    return conversationsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromDocument(doc, currentUserId))
            .toList());
  }

  // Get conversations for a user
  Future<List<Conversation>> getConversations(String userId) async {
    try {
      QuerySnapshot snapshot = await conversationsRef
          .where('participants', arrayContains: userId)
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs.map((doc) => Conversation.fromDocument(doc)).toList();
    } catch (e) {
      print('DatabaseService: Failed to fetch conversations: $e');
      return [];
    }
  }

  // Method to delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await productsRef.doc(productId).delete();
      print('Product deleted: $productId');
    } catch (e) {
      print('DatabaseService: Failed to delete product: $e');
      throw e;
    }
  }

  // Get all products
  Stream<List<Product>> get productsStream {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  // Get products by seller ID
  Stream<List<Product>> getSellerProducts(String sellerId) {
    return _db
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  // Add a new product
  Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _db.collection('products').add(
        product.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product');
    }
  }

  // Update a product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _db.collection('products').doc(productId).update(data);
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product');
    }
  }

  // Mark product as sold
  Future<void> markProductAsSold(String productId, String buyerId) async {
    try {
      await _db.collection('products').doc(productId).update({
        'isSold': true,
        'buyerId': buyerId,
        'soldAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking product as sold: $e');
      throw Exception('Failed to mark product as sold');
    }
  }

  // Search products
  Stream<List<Product>> searchProducts(String query) {
    // Convert query to lowercase for case-insensitive search
    query = query.toLowerCase();
    
    return _db
        .collection('products')
        .where('isSold', isEqualTo: false)
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }
}