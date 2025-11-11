import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class LiquidGradientBackground extends StatefulWidget {
  const LiquidGradientBackground({super.key});

  @override
  State<LiquidGradientBackground> createState() => _LiquidGradientBackgroundState();
}

class _LiquidGradientBackgroundState extends State<LiquidGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: kIsWeb ? 20 : 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return RepaintBoundary(
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _LiquidPainter(progress: _controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _LiquidPainter extends CustomPainter {
  _LiquidPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = Paint()..color = const Color(0xFF070A12); // casi negro azulado
    canvas.drawRect(Offset.zero & size, base);

    // Parámetros de "gotas" azules
    final blobPaint = Paint()..blendMode = BlendMode.plus; // mezcla aditiva

    // Tres blobs con gradiente radial que se mueven en trayectorias senoidales
    final blobs = <_Blob>[
      _Blob(
        center: center + Offset(
          math.sin(progress * 2 * math.pi) * size.width * 0.20,
          math.cos(progress * 2 * math.pi) * size.height * 0.10,
        ),
        radius: size.shortestSide * 0.35,
        inner: const Color(0xFF0D47A1), // azul profundo
        outer: const Color(0x001B2A4A),
      ),
      _Blob(
        center: center + Offset(
          math.sin((progress + 0.33) * 2 * math.pi) * size.width * 0.25,
          math.sin((progress + 0.33) * 2 * math.pi) * size.height * 0.18,
        ),
        radius: size.shortestSide * 0.30,
        inner: const Color(0xFF1565C0),
        outer: const Color(0x000D1B2A),
      ),
      _Blob(
        center: center + Offset(
          math.cos((progress + 0.66) * 2 * math.pi) * size.width * 0.22,
          math.sin((progress + 0.66) * 2 * math.pi) * size.height * 0.22,
        ),
        radius: size.shortestSide * 0.32,
        inner: const Color(0xFF1E88E5),
        outer: const Color(0x000A1526),
      ),
    ];

    for (final b in blobs) {
      final shader = RadialGradient(
        colors: [b.inner, b.outer],
      ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      blobPaint.shader = shader;
      canvas.drawCircle(b.center, b.radius, blobPaint);
    }

    // Sutil viñeta para dar profundidad
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
      ).createShader(Rect.fromCircle(center: center, radius: size.longestSide * 0.75));
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) => oldDelegate.progress != progress;
}

class _Blob {
  _Blob({required this.center, required this.radius, required this.inner, required this.outer});
  final Offset center;
  final double radius;
  final Color inner;
  final Color outer;
}
