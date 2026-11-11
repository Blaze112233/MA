import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null;

  void setUser(UserModel user, String? token) {
    _currentUser = user;
    _token = token;
    notifyListeners();
  }

  void updateUserProfile({String? name, String? phone, String? address, String? avatarUrl}) {
    if (_currentUser == null) return;
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      address: address ?? _currentUser!.address,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}