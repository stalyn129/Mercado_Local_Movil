import 'package:flutter/material.dart';
import '../data/models/producto.dart';
import '../data/models/carrito_item.dart';

class CarritoProvider extends ChangeNotifier {
  List<CarritoItem> items = [];

  void agregarItem(Producto producto, int cantidad) {
    final index = items.indexWhere((e) => e.idProducto == producto.idProducto);

    if (index != -1) {
      items[index].cantidad += cantidad;
    } else {
      items.add(CarritoItem(
        idProducto: producto.idProducto,
        nombreProducto: producto.nombreProducto,
        precio: producto.precioProducto,
        cantidad: cantidad,
        imagen: producto.imagenProducto,
      ));
    }

    notifyListeners();
  }
}
