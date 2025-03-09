import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get usersRef => _db.collection('users');
  CollectionReference get productsRef => _db.collection('products');
  CollectionReference get messagesRef => _db.collection('messages');
  CollectionReference get conversationsRef => _db.collection('conversations');

  // User Methods
  Future<void> createUser(AppUser user) async {
    await usersRef.doc(user.uid).set(user.toMap());
  }

  Stream<AppUser?> userStream(String uid) {
    return usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromDocument(doc);
      }
      return null;
    });
  }

  Future<bool> checkUserExists(String uid) async {
    DocumentSnapshot doc = await usersRef.doc(uid).get();
    return doc.exists;
  }

  Future<AppUser> getUser(String uid) async {
    DocumentSnapshot doc = await usersRef.doc(uid).get();
    return AppUser.fromDocument(doc);
  }

  Future<void> updateUser(AppUser user) async {
    await usersRef.doc(user.uid).update(user.toMap());
  }

  // Product Methods
  Stream<List<Product>> get productsStream {
    return productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  Stream<List<Product>> getSellerProducts(String sellerId) {
    return productsRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  // Alias for getSellerProducts to maintain compatibility
  Stream<List<Product>> getUserProducts(String userId) {
    return getSellerProducts(userId);
  }

  Future<String> addProduct(Product product) async {
    try {
      print('DatabaseService: Starting to add product');
      print('DatabaseService: Product data: ${product.toFirestore()}');

      // Verify Firestore instance
      if (_db == null) {
        throw Exception('Firestore instance is null');
      }

      // Verify collection reference
      final productsCollection = _db.collection('products');
      if (productsCollection == null) {
        throw Exception('Products collection reference is null');
      }

      print('DatabaseService: Adding document to Firestore...');
      final docRef = await productsCollection.add(product.toFirestore());
      print('DatabaseService: Document added with ID: ${docRef.id}');

      // Verify the document was created
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Document was not created successfully');
      }

      return docRef.id;
    } catch (e, stackTrace) {
      print('DatabaseService Error: $e');
      print('Stack trace: $stackTrace');
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. Please check if you are logged in.');
      }
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await productsRef.doc(productId).update(data);
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await productsRef.doc(productId).delete();
      print('Product deleted: $productId');
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Failed to delete product');
    }
  }

  Future<void> markProductAsSold(String productId, String buyerId) async {
    try {
      await productsRef.doc(productId).update({
        'isSold': true,
        'buyerId': buyerId,
        'soldAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking product as sold: $e');
      throw Exception('Failed to mark product as sold');
    }
  }

  Stream<List<Product>> searchProductsStream(String query) {
    query = query.toLowerCase();
    return productsRef
        .where('isSold', isEqualTo: false)
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  Stream<List<Product>> filterProductsStream({
    double? minPrice,
    double? maxPrice,
    String? category,
  }) {
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

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Message Methods
  Future<void> sendMessage(String chatId, String content, String senderId, String receiverId) async {
    await conversationsRef.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await conversationsRef.doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastMessage': content,
      'receiverId': receiverId,
      'receiverName': 'Receiver Name',
      'receiverAvatarUrl': 'https://example.com/avatar.png',
    }, SetOptions(merge: true));
  }

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

  Future<List<Conversation>> getConversations(String userId) async {
    try {
      QuerySnapshot snapshot = await conversationsRef
          .where('participants', arrayContains: userId)
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs.map((doc) => Conversation.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // User Stats Methods
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get active listings count
      final activeListings = await productsRef
          .where('sellerId', isEqualTo: userId)
          .where('isSold', isEqualTo: false)
          .count()
          .get();

      // Get sold items count and total earnings
      final soldProducts = await productsRef
          .where('sellerId', isEqualTo: userId)
          .where('isSold', isEqualTo: true)
          .get();

      double totalEarnings = 0;
      for (var doc in soldProducts.docs) {
        totalEarnings += (doc.data() as Map<String, dynamic>)['price'] ?? 0;
      }

      // Get user ratings
      final ratingsSnapshot = await usersRef
          .doc(userId)
          .collection('ratings')
          .get();

      double totalRating = 0;
      int totalRatings = ratingsSnapshot.docs.length;

      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }

      double averageRating = totalRatings > 0 ? totalRating / totalRatings : 0;

      return {
        'activeListings': activeListings.count,
        'soldItems': soldProducts.docs.length,
        'totalEarnings': totalEarnings,
        'rating': averageRating,
        'totalRatings': totalRatings,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'activeListings': 0,
        'soldItems': 0,
        'totalEarnings': 0.0,
        'rating': 0.0,
        'totalRatings': 0,
      };
    }
  }

  Stream<List<Product>> getSoldProducts(String userId) {
    return productsRef
        .where('sellerId', isEqualTo: userId)
        .where('isSold', isEqualTo: true)
        .orderBy('soldAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  Stream<List<Product>> getPurchasedProducts(String userId) {
    return productsRef
        .where('buyerId', isEqualTo: userId)
        .where('isSold', isEqualTo: true)
        .orderBy('soldAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
  }

  Future<void> rateUser(String userId, String raterId, double rating, String comment) async {
    try {
      await usersRef.doc(userId).collection('ratings').add({
        'rating': rating,
        'comment': comment,
        'raterId': raterId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user's average rating
      final stats = await getUserStats(userId);
      await usersRef.doc(userId).update({
        'averageRating': stats['rating'],
        'totalRatings': stats['totalRatings'],
      });
    } catch (e) {
      print('Error rating user: $e');
      throw Exception('Failed to submit rating');
    }
  }

  Future<void> incrementProductViews(String productId) async {
    try {
      await productsRef.doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing product views: $e');
      // Don't throw here as this is not critical
    }
  }
}