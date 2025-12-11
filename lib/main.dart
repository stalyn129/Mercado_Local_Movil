import 'package:flutter/material.dart';
import 'package:mercado_local_movil/presentation/auth/register_page.dart';
import 'package:mercado_local_movil/providers/register_provider.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/consumer/consumer_main_page.dart';

import 'package:mercado_local_movil/presentation/explorar/explorar_page.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
      ],
      child: const MercadoLocalApp(),
    ),
  );
}

class MercadoLocalApp extends StatelessWidget {
  const MercadoLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      routes: {
        "/login": (_) => LoginPage(),
        "/register": (_) => RegisterPage(),

        // ESTA ES LA PANTALLA QUE DEBE CONTENER EL NAVBAR
        "/consumer": (_) => ConsumerMainPage(),
      },
    );
  }
}
