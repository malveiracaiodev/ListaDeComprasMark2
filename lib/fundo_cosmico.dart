import 'package:flutter/material.dart';
import 'dart:math';

class FundoCosmico extends StatefulWidget {
  final Widget child;
  final int quantidadeEstrelas;

  const FundoCosmico({
    required this.child,
    this.quantidadeEstrelas = 100,
    super.key,
  });

  @override
  State<FundoCosmico> createState() => _FundoCosmicoState();
}

class _FundoCosmicoState extends State<FundoCosmico>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Estrela> _estrelas;
  final random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _estrelas = List.generate(widget.quantidadeEstrelas, (index) {
        final left = random.nextDouble() * size.width;
        final top = random.nextDouble() * size.height;
        final tamanho = random.nextDouble() * 2 + 1;
        final brilho = random.nextDouble() * 0.8 + 0.2;
        final velocidade = random.nextDouble() * 0.5 + 0.2;
        return _Estrela(left, top, tamanho, brilho, velocidade);
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Fundo gradiente cósmico
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Colors.black],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Estrelas animadas
            ..._estrelas.map((estrela) {
              estrela.top -= estrela.velocidade;
              if (estrela.top < 0) {
                estrela.top = size.height;
                estrela.left = random.nextDouble() * size.width;
              }
              return Positioned(
                top: estrela.top,
                left: estrela.left,
                child: Container(
                  height: estrela.tamanho,
                  width: estrela.tamanho,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: estrela.brilho),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            // Conteúdo principal
            SafeArea(child: widget.child),
          ],
        );
      },
    );
  }
}

class _Estrela {
  double left;
  double top;
  double tamanho;
  double brilho;
  double velocidade;

  _Estrela(this.left, this.top, this.tamanho, this.brilho, this.velocidade);
}
