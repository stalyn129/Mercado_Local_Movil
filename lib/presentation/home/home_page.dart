import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> productos = [];
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();
  double scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    fetchProductos();

    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProductos() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('🔄 Intentando conectar al backend...');

      // Para emulador Android usa 10.0.2.2
      // Para emulador iOS o web usa localhost
      // Para dispositivo físico usa la IP de tu computadora (ej: 192.168.1.100)
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/productos/top'),
      ).timeout(const Duration(seconds: 10));

      print('📡 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          productos = data;
          isLoading = false;
        });
        print('✅ Productos cargados exitosamente: ${productos.length}');
      } else {
        print('❌ Error en respuesta: ${response.statusCode}');
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      setState(() {
        isLoading = false;
        productos = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo conectar al servidor. Verifica que el backend esté corriendo.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: fetchProductos,
            ),
          ),
        );
      }
    }
  }

  void realizarBusqueda() {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un término de búsqueda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/explorar',
      arguments: _searchController.text.trim(),
    );
  }

  void mostrarDetalleProducto(dynamic producto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductoDetalle(producto: producto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7EF),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // HERO SECTION CON PARALLAX - OPTIMIZADO PARA MÓVIL
          SliverAppBar(
            expandedHeight: isMobile ? 280 : 400,
            pinned: false,
            backgroundColor: const Color(0xFFFAF7EF),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Fondo con imágenes parallax - SIMPLIFICADO PARA MÓVIL
                  if (!isMobile && productos.isNotEmpty)
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(0, scrollOffset * 0.5),
                        child: Opacity(
                          opacity: 0.15,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  productos[index % productos.length]['imagenProducto'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(color: const Color(0xFFECF2E3));
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Contenido central
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Título
                          Text(
                            'Mercado Local – IA',
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3A5A40),
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: isMobile ? 20 : 32),

                          // Barra de búsqueda - MEJORADA PARA MÓVIL
                          Container(
                            constraints: const BoxConstraints(maxWidth: 600),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.98),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6B8E4E).withOpacity(0.25),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFF4E8C1).withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: isMobile ? 16 : 20),
                                Text('🔍', style: TextStyle(fontSize: isMobile ? 18 : 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar productos...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                    onSubmitted: (_) => realizarBusqueda(),
                                  ),
                                ),
                                InkWell(
                                  onTap: realizarBusqueda,
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 18 : 24,
                                      vertical: isMobile ? 10 : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6B8E4E),
                                          Color(0xFF5A7A3D),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6B8E4E).withOpacity(0.2),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '✓',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobile ? 18 : 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GRID DE PRODUCTOS - OPTIMIZADO PARA MÓVIL
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Título
                Text(
                  'Productos Disponibles',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3A5A40),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Línea decorativa
                Center(
                  child: Container(
                    width: 70,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B8E4E),
                          Color(0xFFF4E8C1),
                          Color(0xFF3A5A40),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtítulo
                Text(
                  'Selecciona un producto para ver más detalles',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: const Color(0xFF6B8E4E),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Grid
                isLoading
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        CircularProgressIndicator(
                          color: Color(0xFF6B8E4E),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando productos...',
                          style: TextStyle(
                            color: Color(0xFF6B8E4E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : productos.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text(
                          '📦',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay productos disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B8E4E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Verifica que el backend esté corriendo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7F69),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: fetchProductos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B8E4E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : (screenWidth > 900 ? 4 : 3),
                    crossAxisSpacing: isMobile ? 12 : 16,
                    mainAxisSpacing: isMobile ? 12 : 16,
                    childAspectRatio: isMobile ? 0.7 : 0.75,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];

                    return GestureDetector(
                      onTap: () => mostrarDetalleProducto(producto),
                      child: Hero(
                        tag: 'producto-${producto['idProducto']}',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagen
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        producto['imagenProducto'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: const Color(0xFFECF2E3),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Color(0xFF6B8E4E),
                                                size: 40,
                                              ),
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: const Color(0xFFECF2E3),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                color: const Color(0xFF6B8E4E),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Badge - MÁS PEQUEÑO EN MÓVIL
                                      if (!isMobile)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF6B8E4E).withOpacity(0.95),
                                                  const Color(0xFF5A7A3D).withOpacity(0.95),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              '⭐',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Info
                              Padding(
                                padding: EdgeInsets.all(isMobile ? 10 : 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto['nombreProducto'] ?? 'Sin nombre',
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D3E2B),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${producto['precioProducto'] ?? '0'}',
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF5A8F48),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// MODAL DE DETALLE DEL PRODUCTO
class ProductoDetalle extends StatelessWidget {
  final dynamic producto;

  const ProductoDetalle({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle del modal
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Imagen principal
                Stack(
                  children: [
                    Container(
                      height: isMobile ? 250 : 300,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF5F2E8), Color(0xFFFAF7EF)],
                        ),
                      ),
                      child: Image.network(
                        producto['imagenProducto'] ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Color(0xFF6B8E4E),
                            ),
                          );
                        },
                      ),
                    ),

                    // Botón cerrar
                    Positioned(
                      top: 16,
                      right: 16,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ),
                    ),

                    // Badge de stock
                    if (producto['stockProducto'] != null && producto['stockProducto'] > 0)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: producto['stockProducto'] > 10
                                  ? const [Color(0xFF6B8E4E), Color(0xFF5A7A3D)]
                                  : const [Color(0xFFF5C744), Color(0xFFE6B526)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Text(
                            producto['stockProducto'] > 10
                                ? '✓ ${producto['stockProducto']} disponibles'
                                : '⚡ Solo ${producto['stockProducto']} disponibles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Información del producto
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categorías
                      if (producto['nombreCategoria'] != null || producto['nombreSubcategoria'] != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (producto['nombreCategoria'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECF2E3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  producto['nombreCategoria'],
                                  style: const TextStyle(
                                    color: Color(0xFF3A5A40),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (producto['nombreSubcategoria'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4E8C1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  producto['nombreSubcategoria'],
                                  style: const TextStyle(
                                    color: Color(0xFF6B8E4E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Nombre
                      Text(
                        producto['nombreProducto'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3E2B),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Precio
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${producto['precioProducto'] ?? '0'}',
                            style: TextStyle(
                              fontSize: isMobile ? 32 : 36,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF5A8F48),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            producto['unidadMedida'] ?? 'por unidad',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7F69),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Línea decorativa
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B8E4E), Color(0xFFF4E8C1)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Descripción
                      if (producto['descripcionProducto'] != null) ...[
                        const Text(
                          'DESCRIPCIÓN',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3E2B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          producto['descripcionProducto'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7F69),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Vendedor
                      if (producto['nombreVendedor'] != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFCF8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFECF2E3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF6B8E4E), Color(0xFF5A7A3D)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('🌾', style: TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'VENDIDO POR',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF6B7F69),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      producto['nombreVendedor'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2D3E2B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Botón de acción
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/producto/${producto['idProducto']}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A8F48),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🛒', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Text(
                                'Ver Producto Completo',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}