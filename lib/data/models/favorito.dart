class Favorito {
  final int idFavorito;
  final int idProducto;
  final String nombreProducto;
  final double precioProducto;
  final String imagenProducto;

  Favorito({
    required this.idFavorito,
    required this.idProducto,
    required this.nombreProducto,
    required this.precioProducto,
    required this.imagenProducto,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      idFavorito: json["idFavorito"],
      idProducto: json["idProducto"],
      nombreProducto: json["nombreProducto"],
      precioProducto: (json["precioProducto"] as num).toDouble(),
      imagenProducto: json["imagenProducto"],
    );
  }
}
