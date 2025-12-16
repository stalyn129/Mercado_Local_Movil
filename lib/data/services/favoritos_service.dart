// lib/data/services/favoritos_service.dart

import '../api/api_client.dart';
import '../api/endpoints.dart';

class FavoritosService {
  final ApiClient api = ApiClient();

  // ================= LISTAR =================
  Future<List> listar(int idConsumidor, String token) async {
    final res = await api.get(
      "${Endpoints.favoritosListar}/$idConsumidor",
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return res.data;
  }

  // ================= AGREGAR =================
  Future<void> agregar(int idProducto, int idConsumidor, String token) async {
    await api.post(
      Endpoints.favoritosAgregar,
      {
        "idProducto": idProducto,
        "idConsumidor": idConsumidor,
      },
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  // ================= ELIMINAR =================
  Future<void> eliminar(int idFavorito, String token) async {
    await api.delete(
      "${Endpoints.favoritosEliminar}/$idFavorito",
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}
