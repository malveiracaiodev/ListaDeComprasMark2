import 'package:flutter/material.dart';
import 'fundo_cosmico.dart';

class PaginaBase extends StatelessWidget {
  final String titulo;
  final Widget conteudo;

  const PaginaBase({required this.titulo, required this.conteudo, super.key});

  @override
  Widget build(BuildContext context) {
    return FundoCosmico(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(titulo),
          backgroundColor: Colors.black,
        ),
        body: conteudo,
      ),
    );
  }
}

// Estilo global para botões
ButtonStyle estiloBotao() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[800], // fundo cinza
    foregroundColor: Colors.cyan, // texto azul ciano
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
}
