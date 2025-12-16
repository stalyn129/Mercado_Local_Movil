// lib/presentation/consumer/consumer_main_page.dart
// ✅ VERSIÓN CORREGIDA - Con callback para FavoritosPage

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

  // ✅ Método para cambiar de pestaña
  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Las páginas se crean aquí en el build para poder pasar _changeTab
    final List<Widget> pages = [
      HomePage(),
      ExplorarPage(),
      FavoritosPage(onTabChange: _changeTab), // ✅ Pasa el callback
      CarritoPage(),
      PerfilPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: CurvedBottomNav(
        index: _currentIndex,
        onTap: _changeTab,
      ),
    );
  }
}