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
      DocumentReference docRef = await productsRef.add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product');
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
}