import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  String? token;
  Map<String, dynamic>? user;
  bool loading = false;

  Future<bool> login(String correo, String pass) async {
    loading = true;
    notifyListeners();

    final ok = await _service.login(correo, pass);

    if (ok) {
      token = await _service.getToken();
      user = await _service.getUser();
    }

    loading = false;
    notifyListeners();
    return ok;
  }
}
