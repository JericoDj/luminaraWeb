import 'package:flutter/material.dart';

import '../utils/storage/user_storage.dart';

class UserProvider with ChangeNotifier {
  final UserStorage _userStorage = UserStorage();

  String? _uid;
  String? _fullName;
  String? _companyId;

  String? get uid => _uid;

  String? get fullName => _fullName;

  String? get companyId => _companyId;

  bool get isLoggedIn => _uid != null;

  Future<void> loadUserData() async {
    _uid = _userStorage.getUid();
    _fullName = _userStorage.getFullName();
    _companyId = _userStorage.getCompanyId();

    print(_uid);
    notifyListeners();
  }
}