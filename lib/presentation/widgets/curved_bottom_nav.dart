import 'package:flutter/material.dart';

class CurvedBottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const CurvedBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A5A40),
            Color(0xFF2D4832),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        child: Stack(
          children: [
            // Línea brillante superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Íconos de navegación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home_rounded, 0, 'Inicio'),
                  _navItem(Icons.shopping_bag_rounded, 1, 'Explorar'),
                  _navItem(Icons.favorite_rounded, 2, 'Favoritos'),
                  _navItem(Icons.shopping_cart_rounded, 3, 'Carrito'),
                  _navItem(Icons.person_rounded, 4, 'Perfil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int i, String label) {
    final isActive = i == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 75,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Efecto de resplandor cuando está activo
              if (isActive)
                Positioned(
                  top: 12,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD48F27).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              // Contenedor del ícono
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(isActive ? 10 : 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Color(0xFFD48F27)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                        BoxShadow(
                          color: Color(0xFFD48F27).withOpacity(0.5),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ]
                          : [],
                    ),
                    child: AnimatedScale(
                      duration: Duration(milliseconds: 300),
                      scale: isActive ? 1.0 : 0.95,
                      child: Icon(
                        icon,
                        size: isActive ? 28 : 24,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Indicador de selección
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isActive ? 6 : 0,
                    height: isActive ? 6 : 0,
                    decoration: BoxDecoration(
                      color: Color(0xFFD48F27),
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                        BoxShadow(
                          color: Color(0xFFD48F27).withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                          : [],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}