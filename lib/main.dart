import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'historicopage.dart';
import 'listaprovider.dart';
import 'listapage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ListaProvider(),
      child: const ListaComprasApp(),
    ),
  );
}

class ListaComprasApp extends StatelessWidget {
  const ListaComprasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras Cósmica',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.cyan,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.cyan,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.cyan,
        ),
        cardColor: const Color(0xFF1B263B),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.cyan,
        ),
      ),
      initialRoute: '/',
      routes: {
        // Home
        '/': (context) => const HomePage(),

        // Página de compra
        '/comprando': (context) => const ListaPage(),

        // Alias para compatibilidade
        '/lista': (context) => const ListaPage(),

        // Histórico
        '/historico': (context) => const HistoricoPage(),
      },
    );
  }
}
