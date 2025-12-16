// lib/presentation/favoritos/favoritos_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favoritos_provider.dart';
import '../../data/services/auth_service.dart';

class FavoritosPage extends StatefulWidget {
  final Function(int)? onTabChange; // ✅ AGREGADO: Callback

  const FavoritosPage({this.onTabChange, super.key}); // ✅ CON parámetro

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> with TickerProviderStateMixin {
  late AnimationController _floatingController1;
  late AnimationController _floatingController2;
  late AnimationController _floatingController3;
  late AnimationController _floatingController4;

  @override
  void initState() {
    super.initState();

    // Controladores de animación para los círculos flotantes
    _floatingController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _floatingController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _floatingController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _floatingController4 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    Future.microtask(() async {
      final auth = AuthService();
      final user = await auth.getUser();
      final token = await auth.getToken();

      if (user == null || token == null) return;

      final int idConsumidor = user["idConsumidor"];

      if (mounted) {
        Provider.of<FavoritosProvider>(context, listen: false)
            .cargar(idConsumidor, token);
      }
    });
  }

  @override
  void dispose() {
    _floatingController1.dispose();
    _floatingController2.dispose();
    _floatingController3.dispose();
    _floatingController4.dispose();
    super.dispose();
  }

  Future<void> _vaciarFavoritos(BuildContext context, FavoritosProvider provider) async {
    if (provider.favoritos.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Vaciar favoritos?',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3E2B),
          ),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar todos tus productos favoritos?',
          style: TextStyle(color: Color(0xFF6B7F69)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6B7F69)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDA3E52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Vaciar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = AuthService();
      final token = await auth.getToken();

      if (token != null) {
        for (var fav in provider.favoritos) {
          await provider.eliminar(fav["idFavorito"], token);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se han vaciado tus favoritos'),
              backgroundColor: Color(0xFF5A8F48),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritosProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FBF7), Color(0xFFECF2E3)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // HEADER ANIMADO - MÁS COMPACTO
            SliverToBoxAdapter(
              child: _buildAnimatedHeader(provider),
            ),

            // CONTENIDO
            provider.loading
                ? SliverFillRemaining(
              child: _buildLoadingState(),
            )
                : provider.favoritos.isEmpty
                ? SliverFillRemaining(
              child: _buildEmptyState(context),
            )
                : SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final fav = provider.favoritos[index];
                    return _buildProductCard(context, fav, provider);
                  },
                  childCount: provider.favoritos.length,
                ),
              ),
            ),

            // Espacio al final
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(FavoritosProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A8F48).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos flotantes animados
          AnimatedBuilder(
            animation: _floatingController1,
            builder: (context, child) {
              return Positioned(
                top: -80 + (_floatingController1.value * 30),
                right: -80 + (_floatingController1.value * 20),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFE5E9).withOpacity(0.6),
                        const Color(0xFFFFD0D9).withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatingController2,
            builder: (context, child) {
              return Positioned(
                top: 100 + (_floatingController2.value * 25),
                right: 40 - (_floatingController2.value * 15),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFDA3E52).withOpacity(0.15),
                        const Color(0xFFB0223E).withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatingController3,
            builder: (context, child) {
              return Positioned(
                bottom: -60 + (_floatingController3.value * 35),
                left: -60 + (_floatingController3.value * 25),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF5A8F48).withOpacity(0.12),
                        const Color(0xFF4A7A3A).withOpacity(0.06),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatingController4,
            builder: (context, child) {
              return Positioned(
                top: 80 - (_floatingController4.value * 20),
                left: 60 + (_floatingController4.value * 15),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFECF2E3).withOpacity(0.8),
                        const Color(0xFFDDE8D0).withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Contenido del header - COMPACTO Y CENTRADO
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 60,
                bottom: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icono más pequeño
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDA3E52).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '❤️',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo
                  Text(
                    'PRODUCTOS GUARDADOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: const Color(0xFF6B7F69).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Título principal
                  const Text(
                    'Tus Favoritos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3E2B),
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Descripción
                  Text(
                    provider.favoritos.isEmpty
                        ? 'Guarda tus productos favoritos'
                        : 'Tienes ${provider.favoritos.length} producto${provider.favoritos.length > 1 ? 's' : ''} guardado${provider.favoritos.length > 1 ? 's' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7F69),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón Vaciar (solo si hay favoritos)
                  if (provider.favoritos.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _vaciarFavoritos(context, provider),
                      icon: const Text('🗑', style: TextStyle(fontSize: 13)),
                      label: const Text(
                        'Vaciar favoritos',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF0F2),
                        foregroundColor: const Color(0xFFDA3E52),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFDA3E52),
                            width: 2,
                          ),
                        ),
                        elevation: 3,
                        shadowColor: const Color(0xFFDA3E52).withOpacity(0.15),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A8F48).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA3E52)),
                backgroundColor: Color(0xFFECF2E3),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Cargando favoritos...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7F69),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ÚNICO CAMBIO: En el botón "Explorar productos"
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A8F48).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono de corazón roto con animación
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFE5E9).withOpacity(0.8),
                          const Color(0xFFFFD0D9).withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDA3E52).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Text(
                      '💔',
                      style: TextStyle(fontSize: 56),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Título principal
            const Text(
              'No tienes productos favoritos aún',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3E2B),
                height: 1.3,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 12),

            // Descripción
            Text(
              'Explora nuestros productos y guarda\ntus favoritos para acceder fácilmente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7F69).withOpacity(0.9),
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 32),

            // ✅ BOTÓN CON EL CAMBIO - Navigator.push a ExplorarPage
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: ElevatedButton(
                onPressed: () {
                  // ✅ Cambia a la pestaña de Explorar (índice 1)
                  widget.onTabChange?.call(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A8F48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0xFF5A8F48).withOpacity(0.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Explorar productos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Indicador visual adicional
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECF2E3).withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Toca el ❤️ en cualquier producto',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF5A8F48).withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> fav, FavoritosProvider provider) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          // Navegar a ProductoDetallePage
          Navigator.pushNamed(
            context,
            '/producto_detalle',
            arguments: fav["idProducto"],
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A8F48).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen con botón eliminar
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      height: 140,
                      color: const Color(0xFFF9FBF7),
                      child: Image.network(
                        fav["imagenProducto"] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Color(0xFF9AAA98),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final auth = AuthService();
                          final token = await auth.getToken();
                          if (token != null) {
                            provider.eliminar(fav["idFavorito"], token);
                          }
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFDA3E52),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '✕',
                              style: TextStyle(
                                color: Color(0xFFDA3E52),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info del producto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fav["nombreProducto"] ?? 'Producto',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3E2B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '\$${fav["precioProducto"]}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5A8F48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navegar a ProductoDetallePage
                            Navigator.pushNamed(
                              context,
                              '/producto_detalle',
                              arguments: fav["idProducto"],
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A8F48),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF5A8F48).withOpacity(0.25),
                          ),
                          child: const Text(
                            'Ver producto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
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
    );
  }
}