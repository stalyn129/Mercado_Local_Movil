import 'dart:convert';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/producto.dart';

class ProductosService {
  final ApiClient _api = ApiClient();

  Future<List<Producto>> getProductos() async {
    final res = await _api.get(Endpoints.productosListar);

    if (res.statusCode != 200) return [];

    // DIO → res.data ES EL JSON
    final List data = res.data;

    return data.map((e) => Producto.fromJson(e)).toList();
  }

  Future<Producto?> getProductoDetalle(int id) async {
    final res = await _api.get("${Endpoints.productoDetalle}/$id");

    if (res.statusCode != 200) return null;

    final Map<String, dynamic> data = res.data;

    return Producto.fromJson(data);
  }
}
