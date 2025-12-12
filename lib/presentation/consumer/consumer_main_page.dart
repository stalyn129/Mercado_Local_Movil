import 'package:flutter/material.dart';
import 'package:mercado_local_movil/presentation/explorar/explorar_page.dart';
import '../widgets/curved_bottom_nav.dart';
import '../home/home_page.dart';
import '../favoritos/favoritos_page.dart';
import '../carrito/carrito_page.dart';
import '../perfil/perfil_page.dart';

class ConsumerMainPage extends StatefulWidget {
  const ConsumerMainPage({super.key});

  @override
  State<ConsumerMainPage> createState() => _ConsumerMainPageState();
}

class _ConsumerMainPageState extends State<ConsumerMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ExplorarPage(),
    FavoritosPage(),
    CarritoPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],

      bottomNavigationBar: CurvedBottomNav(
        index: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}