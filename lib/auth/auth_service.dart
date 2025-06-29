import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milkmate/services/models/customer.dart';
import 'package:milkmate/services/models/partner.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register customer
  Future<User?> registerCustomer({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Create customer document in Firestore
        Customer customer = Customer(
          uid: result.user!.uid,
          name: name,
          email: email.trim(),
          phone: phone,
          address: '', // Will be updated later in profile setup
          city: '', 
          partnerIds: [], // Will be updated later
          preferredTime: '', // Default time
          deliveryQuantity: 0.0, // Default 1 liter
          deliveryType: '', // Default delivery type
          notificationsOn: true,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('customers')
            .doc(result.user!.uid)
            .set(customer.toJson());

        return result.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register partner
  Future<User?> registerPartner({
    required String email,
    required String password,
    required String name,
    required String businessName,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Create partner document in Firestore
        Partner partner = Partner(
          id: result.user!.uid,
          name: name,
          shopName: businessName,
          phone: phone,
          address: '', // Will be updated later in profile setup
          city: '', // Will be updated later in profile setup
          deliveryAreas: [], // Will be updated later
          pricingPerLiter: 0.0, // Will be set later
          isVerified: false, // Admin verification required
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('partners')
            .doc(result.user!.uid)
            .set(partner.toJson());

        return result.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user type (customer or partner)
  Future<String?> getUserType(String uid) async {
    try {
      // Check if user exists in customers collection
      DocumentSnapshot customerDoc = await _firestore
          .collection('customers')
          .doc(uid)
          .get();
      
      if (customerDoc.exists) {
        return 'customer';
      }

      // Check if user exists in partners collection
      DocumentSnapshot partnerDoc = await _firestore
          .collection('partners')
          .doc(uid)
          .get();
      
      if (partnerDoc.exists) {
        return 'partner';
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user type: $e');
    }
  }

  // Get customer data
  Future<Customer?> getCustomerData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('customers')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return Customer.fromJson(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer data: $e');
    }
  }

  // Get partner data
  Future<Partner?> getPartnerData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('partners')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return Partner.fromJson(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get partner data: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}