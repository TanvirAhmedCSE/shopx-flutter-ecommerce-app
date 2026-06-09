import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static String? get currentUid => _auth.currentUser?.uid;
  static String? get currentEmail => _auth.currentUser?.email;

  // Auth
  static Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    }
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Profile
  static Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String avatarPath,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'avatarPath': avatarPath,
      'email': currentEmail ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> syncEmail(String uid, String email) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
    }, SetOptions(merge: true));
  }

  // Orders
  static Future<void> saveOrder(String uid, OrderModel order) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(order.orderId)
        .set(order.toMap());
  }

  static Future<List<OrderModel>> fetchOrders(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('placedAt', descending: true)
        .get();
    return snap.docs.map((d) => OrderModel.fromMap(d.data())).toList();
  }
}
