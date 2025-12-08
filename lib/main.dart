import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/home/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
        "/home": (_) => HomePage(),
      },
    );
  }
}
