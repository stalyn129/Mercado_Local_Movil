// lib/data/models/carrito_item.dart

class CarritoItem {
  final int idProducto;
  final String nombreProducto;
  final double precio;
  int cantidad;
  final String imagen;

  CarritoItem({
    required this.idProducto,
    required this.nombreProducto,
    required this.precio,
    required this.cantidad,
    required this.imagen,
  });
}
