import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userCollection = 'customeruser';

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(userCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> updateUserAddresses(String uid, List<AddressModel> addresses) async {
    final addressesMapList = addresses.map((a) => a.toMap()).toList();
    await _firestore.collection(userCollection).doc(uid).set({
      'addresses': addressesMapList,
    }, SetOptions(merge: true));
  }
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection(userCollection).doc(user.uid).set({
      'name': user.name,
      'phone': user.phone,
      // 'email': user.email, // Optional: usually email is not updated
      'role': user.role,
      'addresses': user.addresses.map((a) => a.toMap()).toList(),
    }, SetOptions(merge: true));
  }
}

