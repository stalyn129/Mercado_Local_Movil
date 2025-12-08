import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mercado_local_movil/core/config/env.dart';

class AuthService {
  Future<String?> login(String correo, String pass) async {
    final url = Uri.parse("${Env.apiUrl}/auth/login");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "contrasena": pass,
      }),
    );

    print("STATUS: ${resp.statusCode}");
    print("BODY: ${resp.body}");

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data["token"];
    }

    return null;
  }
}
