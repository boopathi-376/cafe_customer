import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../core/constants/firestore_paths.dart';
import '../core/error/app_exception.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;

      if (!user.emailVerified) {
        await _auth.signOut();
        throw const AppException(
            'Please verify your email before logging in. Check your inbox.');
      }

      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw const AppException('Account not found.');
      }

      return UserModel.fromMap(doc.data()!, user.uid);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw const AppException('An unexpected error occurred.');
    }
  }

  Future<UserModel?> register(
    String email,
    String password,
    String name, {
    String phone = '',
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user!.updateDisplayName(name);

      await result.user!.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://cafe-83d88.firebaseapp.com/verified',
          handleCodeInApp: false,
          androidPackageName: 'com.example.cafe',
          androidInstallApp: true,
          androidMinimumVersion: '1',
        ),
      );

      final newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: 'customer',
        addresses: [],
      );

      await _firestore
          .collection(FirestorePaths.users)
          .doc(result.user!.uid)
          .set(newUser.toMap());

      // Do NOT sign out here — keep user signed in so we can
      // call reload() to check verification status later
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    } catch (e) {
      throw const AppException('Registration failed. Please try again.');
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      // ActionCodeSettings makes the email show "Happy Mug" as the app name
      // and uses a continue URL that looks professional
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://cafe-83d88.firebaseapp.com/verified',
          handleCodeInApp: false,
          androidPackageName: 'com.example.cafe',
          androidInstallApp: true,
          androidMinimumVersion: '1',
        ),
      );
    }
  }

  /// Reloads the current user from Firebase and returns verified status.
  /// Works correctly whether user is freshly registered or returning.
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      // Force reload from Firebase server to get latest emailVerified flag
      await user.reload();
      // Must re-fetch currentUser after reload — the old reference is stale
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream that emits UserModel when auth state changes.
  /// Only emits a non-null value when email is verified.
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      // Don't load profile for unverified users
      if (!user.emailVerified) return null;
      try {
        final doc = await _firestore
            .collection(FirestorePaths.users)
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!, user.uid);
        }
        return null;
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> addAddress(String uid, AddressModel newAddress) async {
    final docRef = _firestore.collection(FirestorePaths.users).doc(uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final current = List<dynamic>.from(snap.data()?['addresses'] ?? []);
      current.add(newAddress.toMap());
      tx.update(docRef, {'addresses': current});
    });
  }

  Future<void> setCurrentAddress(String uid, String selectedAddress) async {
    final docRef = _firestore.collection(FirestorePaths.users).doc(uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final current = List<dynamic>.from(snap.data()?['addresses'] ?? []);
      final updated = current.map((a) {
        final m = Map<String, dynamic>.from(a as Map);
        m['isCurrent'] = m['address'] == selectedAddress;
        return m;
      }).toList();
      tx.update(docRef, {'addresses': updated});
    });
  }
}
