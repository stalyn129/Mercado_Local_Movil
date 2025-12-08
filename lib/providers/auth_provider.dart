import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  String? token;
  bool loading = false;

  Future<bool> login(String correo, String pass) async {
    loading = true;
    notifyListeners();

    token = await _service.login(correo, pass);

    loading = false;
    notifyListeners();

    return token != null;
  }
}
