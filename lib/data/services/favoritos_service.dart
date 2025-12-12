import '../api/api_client.dart';
import '../api/endpoints.dart';

class FavoritosService {
  final ApiClient _api = ApiClient();

  Future<bool> agregarFavorito(
      int idConsumidor,
      int idProducto, {
        String? token,
      }) async {
    final body = {
      "idConsumidor": idConsumidor,
      "idProducto": idProducto,
    };

    final headers = <String, String>{
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await _api.post(
      Endpoints.favoritosAgregar,
      body,
      headers: headers,
    );

    return res.statusCode == 200;
  }
}
