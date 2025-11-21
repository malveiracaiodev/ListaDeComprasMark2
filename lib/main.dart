import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'listapreparadapage.dart';
import 'historicopage.dart';
import 'fundo_cosmico.dart';
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
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1B263B),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0D1B2A),
        ),
      ),
      initialRoute: '/',
      routes: {
        // Home
        '/': (context) => const FundoCosmico(child: HomePage()),

        // Preparar lista
        '/preparar': (context) => const FundoCosmico(child: ListaPreparadaPage()),

        // Página de compra (nome canonical: '/comprando')
        '/comprando': (context) => const FundoCosmico(child: ListaPage()),

        // Alias para compatibilidade: se outras partes do app usam '/lista'
        '/lista': (context) => const FundoCosmico(child: ListaPage()),

        // Histórico
        '/historico': (context) => const FundoCosmico(child: HistoricoPage()),
      },
    );
  }
}
