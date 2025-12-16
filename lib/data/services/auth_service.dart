// lib/data/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080";

  // ================= LOGIN =================
  Future<bool> login(String correo, String pass) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "contrasena": pass,
      }),
    );

    print("STATUS LOGIN: ${resp.statusCode}");
    print("BODY LOGIN: ${resp.body}");

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);

      final prefs = await SharedPreferences.getInstance();

      // 🔐 Guardar token
      prefs.setString("token", data["token"]);

// 👤 Guardar usuario COMPLETO (como viene del backend)
      prefs.setString("user", jsonEncode(data));

// 🆔 Guardar idConsumidor DIRECTO
      if (data["idConsumidor"] != null) {
        prefs.setInt("idConsumidor", data["idConsumidor"]);
      }


      return true;
    }

    return false;
  }

  // ================= GET USER =================
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("user");

    if (jsonString == null) return null;

    return jsonDecode(jsonString);
  }

  // ================= GET TOKEN =================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ================= LOGOUT (OPCIONAL) =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
