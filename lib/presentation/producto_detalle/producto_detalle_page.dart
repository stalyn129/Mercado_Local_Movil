import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProductoDetallePage extends StatefulWidget {
  final int idProducto;

  const ProductoDetallePage({super.key, required this.idProducto});

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> with TickerProviderStateMixin {
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

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _animationsInitialized = true;
    cargarProducto();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> cargarProducto() async {
    try {
      final res = await dio.get("$API_URL/productos/detalle/${widget.idProducto}");
      setState(() {
        producto = res.data;
        loading = false;
      });
      if (_animationsInitialized) {
        _fadeController.forward();
        _scaleController.forward();
      }
    } catch (e) {
      print("Error cargando detalle: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xffF9FBF7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff5A8F48),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Cargando producto...",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff2D3E2B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (producto == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF9FBF7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text("Producto no encontrado"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF9FBF7),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff5A8F48), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xff5A8F48), size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_animationsInitialized)
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _imagenPrincipal(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoProducto(),
                            const SizedBox(height: 24),
                            _accionesProducto(),
                            const SizedBox(height: 24),
                            _descripcion(),
                            const SizedBox(height: 24),
                            _valoraciones(),
                            const SizedBox(height: 24),
                            _agregarResena(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (showEnvio || showReembolso)
            _buildModalOverlay(),
        ],
      ),
    );
  }

  Widget _imagenPrincipal() {
    return Hero(
      tag: 'producto_${widget.idProducto}',
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade100,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                producto!["imagenProducto"],
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xffF9FBF7).withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoProducto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                producto!["nombreProducto"],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3E2B),
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.0, end: favorito ? 1.0 : 0.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (value * 0.2),
                  child: IconButton(
                    onPressed: () => setState(() => favorito = !favorito),
                    icon: Icon(
                      favorito ? Icons.favorite : Icons.favorite_border,
                      color: favorito ? Colors.red : Colors.grey.shade400,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade50,
                Colors.orange.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade200, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                5,
                    (index) => Icon(
                  index < (producto!["promedioValoracion"] ?? 0).round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${producto!["promedioValoracion"]?.toStringAsFixed(1) ?? '0.0'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "(${producto!["totalValoraciones"] ?? 0})",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff5A8F48), Color(0xff4A7A3A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff5A8F48).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PRECIO",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "\$",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${producto!["precioProducto"]}",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accionesProducto() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cantidad",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xff2D3E2B),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F5F0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade100, width: 1),
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() {
                              if (cantidad > 1) cantidad--;
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.remove_rounded, color: Color(0xff5A8F48), size: 20),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "$cantidad",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2D3E2B),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => cantidad++),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.add_rounded, color: Color(0xff5A8F48), size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: "Agregar",
                      icon: Icons.shopping_cart_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xff5A8F48), Color(0xff4A7A3A)],
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: "Comprar",
                      icon: Icons.bolt_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xff2D3E2B), Color(0xff1A2318)],
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoButton(
                icon: Icons.local_shipping_outlined,
                label: "Envío",
                color: Colors.blue,
                onPressed: () => setState(() => showEnvio = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoButton(
                icon: Icons.currency_exchange_rounded,
                label: "Reembolso",
                color: Colors.green,
                onPressed: () => setState(() => showReembolso = true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade300.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _descripcion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Descripción",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3E2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            producto!["descripcionProducto"] ?? "Sin descripción",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valoraciones() {
    final lista = producto!["valoraciones"] ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade50, Colors.amber.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Reseñas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3E2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (lista.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.rate_review_outlined, color: Colors.grey.shade400, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Aún no hay reseñas.\n¡Sé el primero en opinar!",
                      style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                    ),
                  ),
                ],
              ),
            )
          else
            ...lista.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xffF9FBF7),
                    Colors.green.shade50.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              (v["nombreConsumidor"] ?? "U")[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            v["nombreConsumidor"] ?? "Usuario",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${v["calificacion"]}",
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    v["comentario"] ?? "",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _agregarResena() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.green.shade50.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff5A8F48), Color(0xff4A7A3A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Agregar Reseña",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D3E2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade200, width: 1),
            ),
            child: DropdownButton<int>(
              value: nuevaValoracion,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.green.shade700),
              items: const [
                DropdownMenuItem(value: 5, child: Text("⭐⭐⭐⭐⭐ Excelente")),
                DropdownMenuItem(value: 4, child: Text("⭐⭐⭐⭐ Muy bueno")),
                DropdownMenuItem(value: 3, child: Text("⭐⭐⭐ Bueno")),
                DropdownMenuItem(value: 2, child: Text("⭐⭐ Regular")),
                DropdownMenuItem(value: 1, child: Text("⭐ Malo")),
              ],
              onChanged: (v) => setState(() => nuevaValoracion = v!),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: "Tu comentario",
              labelStyle: TextStyle(color: Colors.grey.shade600),
              hintText: "Comparte tu experiencia con este producto...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.green.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.green.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xff5A8F48), width: 2),
              ),
            ),
            maxLines: 4,
            onChanged: (v) => nuevoComentario = v,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff5A8F48), Color(0xff4A7A3A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff5A8F48).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Enviar Reseña",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalOverlay() {
    return AnimatedOpacity(
      opacity: showEnvio || showReembolso ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => setState(() {
          showEnvio = false;
          showReembolso = false;
        }),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.8, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: showEnvio
                                  ? [Colors.blue.shade50, Colors.blue.shade100]
                                  : [Colors.green.shade50, Colors.green.shade100],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            showEnvio ? Icons.local_shipping_rounded : Icons.currency_exchange_rounded,
                            color: showEnvio ? Colors.blue.shade700 : Colors.green.shade700,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          showEnvio ? "Política de Envío" : "Política de Reembolso",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2D3E2B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...(showEnvio
                            ? [
                          "✓ Envío en 24-48 horas",
                          "✓ Entregas dentro de ciudad",
                          "✓ Producto fresco garantizado"
                        ]
                            : [
                          "✓ Reembolso hasta 48h tras entrega",
                          "✓ Requiere evidencia",
                          "✗ No cubre daños por mal uso"
                        ])
                            .map((texto) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xffF9FBF7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            texto,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        )),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => setState(() {
                              showEnvio = false;
                              showReembolso = false;
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff5A8F48),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Entendido",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}