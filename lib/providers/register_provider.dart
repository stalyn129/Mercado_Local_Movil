import 'package:flutter/material.dart';
import '../data/services/register_service.dart';

class RegisterProvider extends ChangeNotifier {
  final _service = RegisterService();

  bool loading = false;
  String? errorMessage;

  Future<bool> registrar(Map<String, dynamic> data) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _service.register(data);

    loading = false;

    if (result["ok"]) {
      notifyListeners();
      return true;
    } else {
      errorMessage = result["mensaje"] ?? "Error desconocido";
      notifyListeners();
      return false;
    }
  }
}
