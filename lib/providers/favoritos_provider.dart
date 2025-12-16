// lib/providers/favoritos_provider.dart

import 'package:flutter/material.dart';
import '../data/services/favoritos_service.dart';

class FavoritosProvider extends ChangeNotifier {
  final FavoritosService service = FavoritosService();

  List favoritos = [];
  bool loading = false;

  Future<void> cargar(int idConsumidor, String token) async {
    loading = true;
    notifyListeners();

    favoritos = await service.listar(idConsumidor, token);

    loading = false;
    notifyListeners();
  }

  Future<void> eliminar(int idFavorito, String token) async {
    await service.eliminar(idFavorito, token);
    favoritos.removeWhere((f) => f["idFavorito"] == idFavorito);
    notifyListeners();
  }
}
