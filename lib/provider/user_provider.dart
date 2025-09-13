import 'package:flutter/material.dart';
import '../models/user.dart';
import '../service/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    _user = await _userService.getUser(uid);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAddresses(List<AddressModel> updatedAddresses) async {
    if (_user == null) return;
    await _userService.updateUserAddresses(_user!.uid, updatedAddresses);
    _user = _user!.copyWith(addresses: updatedAddresses);
    notifyListeners();
  }
  Future<void> updateUserDetails(UserModel updatedUser) async {
    _user = updatedUser;
    notifyListeners();
    await _userService.updateUser(updatedUser);
  }
  void clearUser() {
    _user = null;
    notifyListeners();
  }

}
