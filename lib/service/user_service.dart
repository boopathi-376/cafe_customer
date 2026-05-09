import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../core/constants/firestore_paths.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> updateUserAddresses(
      String uid, List<AddressModel> addresses) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .set(
          {'addresses': addresses.map((a) => a.toMap()).toList()},
          SetOptions(merge: true),
        );
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .set(
          {
            'name': user.name,
            'phone': user.phone,
            'role': user.role,
            'addresses':
                user.addresses.map((a) => a.toMap()).toList(),
          },
          SetOptions(merge: true),
        );
  }
}
