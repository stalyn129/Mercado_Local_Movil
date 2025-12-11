import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String base = "http://10.0.2.2:8080";

  Future<List> getProductos() async {
    final res = await http.get(Uri.parse("$base/productos/listar"));
    return jsonDecode(res.body);
  }

  Future<List> getCategorias() async {
    final res = await http.get(Uri.parse("$base/categorias/listar"));
    return jsonDecode(res.body);
  }

  Future<List> getSubcategorias() async {
    final res = await http.get(Uri.parse("$base/subcategorias/listar"));
    return jsonDecode(res.body);
  }
}
