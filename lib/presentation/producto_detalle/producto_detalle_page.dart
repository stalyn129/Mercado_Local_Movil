import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProductoDetallePage extends StatefulWidget {
  final int idProducto;

  const ProductoDetallePage({super.key, required this.idProducto});

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  final API_URL = "http://10.0.2.2:8080";
  final dio = Dio();

  Map<String, dynamic>? producto;
  bool loading = true;

  int cantidad = 1;
  bool favorito = false;
  int nuevaValoracion = 5;
  String nuevoComentario = "";

  bool showEnvio = false;
  bool showReembolso = false;

  @override
  void initState() {
    super.initState();
    cargarProducto();
  }

  Future<void> cargarProducto() async {
    try {
      final res = await dio.get("$API_URL/productos/detalle/${widget.idProducto}");
      setState(() {
        producto = res.data;
        loading = false;
      });
    } catch (e) {
      print("Error cargando detalle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || producto == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF9FBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Detalle del Producto",
            style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imagenPrincipal(),

            const SizedBox(height: 20),
            _infoProducto(),

            const SizedBox(height: 20),
            _accionesProducto(),

            const SizedBox(height: 20),
            _descripcion(),

            const SizedBox(height: 20),
            _valoraciones(),

            const SizedBox(height: 20),
            _agregarResena(),
          ],
        ),
      ),

      // MODALES
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showEnvio) _buildModal(
            title: "📦 Política de Envío",
            contenido: [
              "✓ Envío en 24-48 horas",
              "✓ Entregas dentro de ciudad",
              "✓ Producto fresco garantizado"
            ],
            cerrar: () => setState(() => showEnvio = false),
          ),

          if (showReembolso) _buildModal(
            title: "💵 Política de Reembolso",
            contenido: [
              "✓ Reembolso hasta 48h tras entrega",
              "✓ Requiere evidencia",
              "✗ No cubre daños por mal uso"
            ],
            cerrar: () => setState(() => showReembolso = false),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // IMAGEN PRINCIPAL
  // ----------------------------------------------------
  Widget _imagenPrincipal() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        producto!["imagenProducto"],
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
      ),
    );
  }

  // ----------------------------------------------------
  // INFO PRINCIPAL DEL PRODUCTO
  // ----------------------------------------------------
  Widget _infoProducto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto!["nombreProducto"],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xff2D3E2B),
          ),
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 22),
            Text(
              "${producto!["promedioValoracion"] ?? 0}/5",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "(${producto!["totalValoraciones"] ?? 0} reseñas)",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xffF9D94A), Color(0xffF5C542)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("PRECIO", style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),

              Text(
                "\$${producto!["precioProducto"]}",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3E2B),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // ACCIONES: FAVORITO, CANTIDAD, CARRITO, COMPRAR
  // ----------------------------------------------------
  Widget _accionesProducto() {
    return Column(
      children: [
        // CANTIDAD
        Row(
          children: [
            const Text("Cantidad:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xffF2F5F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => setState(() {
                        if (cantidad > 1) cantidad--;
                      }),
                      icon: const Icon(Icons.remove, color: Colors.green)),
                  Text("$cantidad",
                      style: const TextStyle(fontSize: 16)),
                  IconButton(
                      onPressed: () => setState(() => cantidad++),
                      icon: const Icon(Icons.add, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5A8F48),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("🛒 Agregar al Carrito",
                    style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2D3E2B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("⚡ Comprar",
                    style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => favorito = !favorito),
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                    favorito ? Colors.red : Colors.red.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(favorito ? "❤️ Guardado" : "🤍 Guardar",
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => showEnvio = true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("🚚 Envío",
                    style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => showReembolso = true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("💵 Reembolso",
                    style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // DESCRIPCIÓN
  // ----------------------------------------------------
  Widget _descripcion() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.green.shade200.withOpacity(0.15),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📋 Descripción",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3E2B))),
          const SizedBox(height: 12),
          Text(
            producto!["descripcionProducto"] ?? "Sin descripción",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // VALORACIONES
  // ----------------------------------------------------
  Widget _valoraciones() {
    final lista = producto!["valoraciones"] ?? [];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.green.shade200.withOpacity(0.15),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("⭐ Reseñas",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          if (lista.isEmpty)
            const Text("Aún no hay reseñas",
                style: TextStyle(color: Colors.grey)),
          ...lista.map((v) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF9FBF7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(v["nombreConsumidor"] ?? "Usuario",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text("⭐ ${v["calificacion"]}",
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(v["comentario"] ?? ""),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // AGREGAR RESEÑA
  // ----------------------------------------------------
  Widget _agregarResena() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.green.shade200.withOpacity(0.15),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("✍️ Agregar Reseña",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          DropdownButton<int>(
            value: nuevaValoracion,
            items: const [
              DropdownMenuItem(value: 5, child: Text("⭐⭐⭐⭐⭐ Excelente")),
              DropdownMenuItem(value: 4, child: Text("⭐⭐⭐⭐ Muy bueno")),
              DropdownMenuItem(value: 3, child: Text("⭐⭐⭐ Bueno")),
              DropdownMenuItem(value: 2, child: Text("⭐⭐ Regular")),
              DropdownMenuItem(value: 1, child: Text("⭐ Malo")),
            ],
            onChanged: (v) => setState(() => nuevaValoracion = v!),
          ),

          const SizedBox(height: 10),

          TextField(
            decoration: const InputDecoration(
              labelText: "Tu comentario",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (v) => nuevoComentario = v,
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5A8F48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text("Enviar Reseña",
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // MODALES
  // ----------------------------------------------------
  Widget _buildModal({
    required String title,
    required List<String> contenido,
    required VoidCallback cerrar,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: cerrar,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black54,
          ),
        ),
        Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...contenido.map((c) => Text(c)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: cerrar,
                  child: const Text("Cerrar"),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
