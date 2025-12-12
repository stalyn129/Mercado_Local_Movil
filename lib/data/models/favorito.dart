class Favorito {
  final int idFavorito;
  final int idConsumidor;
  final int idProducto;

  Favorito({
    required this.idFavorito,
    required this.idConsumidor,
    required this.idProducto,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      idFavorito: json["idFavorito"],
      idConsumidor: json["idConsumidor"],
      idProducto: json["idProducto"],
    );
  }
}
