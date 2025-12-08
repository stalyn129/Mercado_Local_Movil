import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';

class RegisterService {

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final url = Uri.parse("${Env.apiUrl}/auth/register");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final body = jsonDecode(resp.body);

    print("STATUS REGISTER: ${resp.statusCode}");
    print("BODY: $body");

    if (resp.statusCode == 200) {
      return {
        "ok": true,
        "data": body,
      };
    } else {
      return {
        "ok": false,
        "mensaje": body["mensaje"] ?? "Error al registrar"
      };
    }
  }
}
