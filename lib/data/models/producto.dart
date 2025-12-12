class Producto {
  final int idProducto;
  final String nombreProducto;
  final String descripcionProducto;
  final double precioProducto;
  final String imagenProducto;
  final int idVendedor;

  Producto({
    required this.idProducto,
    required this.nombreProducto,
    required this.descripcionProducto,
    required this.precioProducto,
    required this.imagenProducto,
    required this.idVendedor,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    idProducto: json["idProducto"],
    nombreProducto: json["nombreProducto"],
    descripcionProducto: json["descripcionProducto"],
    precioProducto: json["precioProducto"] + 0.0,
    imagenProducto: json["imagenProducto"],
    idVendedor: json["idVendedor"],
  );
}
