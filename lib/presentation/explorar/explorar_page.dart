import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  final dio = Dio();
  final API_URL = "http://10.0.2.2:8080";

  List productos = [];
  List categorias = [];
  List subcategorias = [];

  String busqueda = "";
  String filtroCategoria = "";
  String filtroSubcategoria = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarTodo();
  }

  Future<void> cargarTodo() async {
    try {
      await Future.wait([
        cargarProductos(),
        cargarCategorias(),
        cargarSubcategorias()
      ]);
    } catch (_) {}
    setState(() => loading = false);
  }

  Future<void> cargarProductos() async {
    try {
      final res = await dio.get("$API_URL/productos/listar");
      productos = res.data;
      setState(() {});
    } catch (e) {
      print("❌ Error cargando productos: $e");
    }
  }

  Future<void> cargarCategorias() async {
    try {
      final res = await dio.get("$API_URL/categorias/listar");
      categorias = res.data;
      setState(() {});
    } catch (e) {
      print("Error cargando categorías: $e");
    }
  }

  Future<void> cargarSubcategorias() async {
    try {
      final res = await dio.get("$API_URL/subcategorias/listar");
      subcategorias = res.data;
      setState(() {});
    } catch (e) {
      print("Error cargando subcategorías: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosFiltrados = productos.where((p) {
      final cumpleBusqueda =
      p["nombreProducto"].toLowerCase().contains(busqueda.toLowerCase());

      final cumpleCat = filtroCategoria.isEmpty
          ? true
          : p["idCategoria"].toString() == filtroCategoria;

      final cumpleSub = filtroSubcategoria.isEmpty
          ? true
          : p["idSubcategoria"].toString() == filtroSubcategoria;

      return cumpleBusqueda && cumpleCat && cumpleSub;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF9FBF7),
      body: SafeArea(
        child: loading
            ? _buildLoader()
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFiltros(),
              const SizedBox(height: 20),
              _buildResultadosInfo(productosFiltrados),
              const SizedBox(height: 16),
              productosFiltrados.isEmpty
                  ? _buildNoResultados()
                  : _buildGrid(productosFiltrados),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // HEADER
  // ----------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.green.shade200.withOpacity(0.2),
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "🛒",
            style: TextStyle(fontSize: 46),
          ),
          const SizedBox(height: 12),
          const Text(
            "Explorar Productos",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff2D3E2B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Descubre nuestros mejores productos orgánicos y sustentables",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff6B7F69),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // FILTROS
  // ----------------------------
  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.green.shade200.withOpacity(0.15),
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // 🔍 BUSCADOR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xffF1F6EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: (v) => setState(() => busqueda = v),
              decoration: const InputDecoration(
                hintText: "Buscar productos frescos...",
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Color(0xff5A8F48)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SELECT CATEGORÍA
          _buildDropdown(
            label: "Categoría",
            value: filtroCategoria,
            items: [
              const DropdownMenuItem(
                  value: "", child: Text("🌿 Todas las categorías")),
              ...categorias.map((c) => DropdownMenuItem(
                value: c["idCategoria"].toString(),
                child: Text(c["nombreCategoria"]),
              ))
            ],
            onChange: (value) {
              setState(() {
                filtroCategoria = value ?? "";
                filtroSubcategoria = "";
              });
            },
          ),

          const SizedBox(height: 12),

          // SELECT SUBCATEGORÍA
          _buildDropdown(
            label: "Subcategoría",
            value: filtroSubcategoria,
            items: [
              const DropdownMenuItem(
                  value: "", child: Text("🍃 Todas las subcategorías")),
              ...subcategorias
                  .where((s) =>
              filtroCategoria.isEmpty ||
                  s["idCategoria"].toString() == filtroCategoria)
                  .map(
                    (s) => DropdownMenuItem(
                  value: s["idSubcategoria"].toString(),
                  child: Text(s["nombreSubcategoria"]),
                ),
              )
            ],
            onChange: (value) =>
                setState(() => filtroSubcategoria = value ?? ""),
          ),

          // BOTÓN LIMPIAR FILTROS
          if (busqueda.isNotEmpty ||
              filtroCategoria.isNotEmpty ||
              filtroSubcategoria.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    busqueda = "";
                    filtroCategoria = "";
                    filtroSubcategoria = "";
                  });
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text("Limpiar filtros"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFFF0F2),
                  foregroundColor: const Color(0xffDA3E52),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xffDA3E52),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffECF2E3), width: 2),
      ),
      child: DropdownButton<String>(
        value: value.isEmpty ? null : value,
        hint: Text(label),
        isExpanded: true,
        underline: Container(),
        items: items,
        onChanged: onChange,
      ),
    );
  }

  // ----------------------------
  // INFO DE RESULTADOS
  // ----------------------------
  Widget _buildResultadosInfo(List productosFiltrados) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.green.shade200.withOpacity(0.1),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Mostrando ",
            style: TextStyle(
              color: Color(0xff6B7F69),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "${productosFiltrados.length}",
            style: const TextStyle(
              color: Color(0xff5A8F48),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            " productos de ",
            style: TextStyle(
              color: Color(0xff6B7F69),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "${productos.length}",
            style: const TextStyle(
              color: Color(0xff5A8F48),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            " disponibles",
            style: TextStyle(
              color: Color(0xff6B7F69),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // NO HAY RESULTADOS
  // ----------------------------
  Widget _buildNoResultados() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.green.shade200.withOpacity(0.1),
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: const [
          Text(
            "🌱",
            style: TextStyle(fontSize: 64),
          ),
          SizedBox(height: 16),
          Text(
            "No hay productos disponibles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff2D3E2B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Intenta ajustar tus filtros de búsqueda",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff9AAA98),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // GRID DE PRODUCTOS
  // ----------------------------
  Widget _buildGrid(List productos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, i) {
        final p = productos[i];
        return GestureDetector(
          // 🔥 NAVEGAR AL DETALLE DEL PRODUCTO
          onTap: () {
            Navigator.pushNamed(
              context,
              '/producto-detalle',
              arguments: p["idProducto"],
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.green.shade200.withOpacity(0.2),
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGEN DEL PRODUCTO
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    p["imagenProducto"],
                    height: 140,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: const Color(0xffF1F6EC),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Color(0xff9AAA98),
                        ),
                      );
                    },
                  ),
                ),

                // INFO DEL PRODUCTO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOMBRE
                        Text(
                          p["nombreProducto"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2D3E2B),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // SUBCATEGORÍA
                        Text(
                          p["nombreSubcategoria"] ?? "Sin categoría",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xff6B7F69),
                          ),
                        ),

                        const Spacer(),

                        // ⭐ VALORACIÓN
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xffFFB800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${p["promedioValoracion"]?.toStringAsFixed(1) ?? "0.0"}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2D3E2B),
                              ),
                            ),
                            Text(
                              " (${p["totalValoraciones"] ?? 0})",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xff6B7F69),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // PRECIO
                        Text(
                          "\$${p["precioProducto"]}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff5A8F48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------
  // LOADER
  // ----------------------------
  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xff5A8F48),
          ),
          SizedBox(height: 16),
          Text(
            "Cargando productos...",
            style: TextStyle(
              color: Color(0xff6B7F69),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}