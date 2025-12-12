import 'package:flutter/material.dart';
import '../data/services/favoritos_service.dart';

class FavoritosProvider extends ChangeNotifier {
  final FavoritosService _service = FavoritosService();

  bool favorito = false;

  Future<void> agregarFavorito(int idConsumidor, int idProducto) async {
    final ok = await _service.agregarFavorito(idConsumidor, idProducto);

    if (ok) {
      favorito = true;
      notifyListeners();
    }
  }
}
