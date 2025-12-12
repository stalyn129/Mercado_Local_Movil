import 'package:flutter/material.dart';
import '../data/models/producto.dart';
import '../data/services/productos_service.dart';

class ProductosProvider extends ChangeNotifier {
  final ProductosService _service = ProductosService();

  List<Producto> productos = [];
  Producto? productoDetalle;

  bool loading = false;

  Future<void> cargarProductos() async {
    loading = true;
    notifyListeners();

    productos = await _service.getProductos();
    loading = false;
    notifyListeners();
  }

  Future<void> cargarProductoDetalle(int id) async {
    productoDetalle = await _service.getProductoDetalle(id);
    notifyListeners();
  }
}
