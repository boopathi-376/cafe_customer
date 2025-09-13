import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userCollection = 'customeruser'; // your Firestore collection

  /// Sign in with email and password (customer only)
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final query = await _firestore
          .collection(userCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("No customer account found for this email.");
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw Exception("User not found.");
      }

      if (!user.emailVerified) {
        throw Exception("Email not verified. Please verify your email.");
      }

      final uid = user.uid;
      final doc = await _firestore.collection(userCollection).doc(uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        throw Exception("Access denied. Customer account only.");
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    } catch (e) {
      throw Exception("Sign-in failed: ${e.toString()}");
    }
  }

  /// Register new customer and send email verification
  Future<UserModel?> register(String email, String password, String name, {String phone = ""}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await result.user!.sendEmailVerification();

      final newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: 'customer',
        addresses: [],
      );

      await _firestore
          .collection(userCollection)
          .doc(result.user!.uid)
          .set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }



  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Auth state changes stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserFromFirestore(user.uid);
    });
  }

  /// Fetch user from Firestore
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection(userCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add new address for user
  Future<void> addAddress(String uid, AddressModel newAddress) async {
    final docRef = _firestore.collection(userCollection).doc(uid);
    final snapshot = await docRef.get();

    List<dynamic> currentAddresses = snapshot.data()?['addresses'] ?? [];

    // Add the new address (as map)
    currentAddresses.add(newAddress.toMap());

    await docRef.update({'addresses': currentAddresses});
  }

  /// Set the current address by marking one as isCurrent
  Future<void> setCurrentAddress(String uid, String selectedAddress) async {
    final docRef = _firestore.collection(userCollection).doc(uid);
    final snapshot = await docRef.get();

    List<dynamic> currentAddresses = snapshot.data()?['addresses'] ?? [];

    final updatedAddresses = currentAddresses.map((addressMap) {
      Map<String, dynamic> map = Map<String, dynamic>.from(addressMap);
      map['isCurrent'] = (map['address'] == selectedAddress);
      return map;
    }).toList();

    await docRef.update({'addresses': updatedAddresses});
  }
}
