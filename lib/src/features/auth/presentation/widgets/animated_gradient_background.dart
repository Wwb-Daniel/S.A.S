import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        final angle = _controller.value * pi * 2;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-cos(angle) * 0.7, -sin(angle) * 0.7),
              end: Alignment(cos(angle) * 0.7, sin(angle) * 0.7),
              colors: <Color>[
                Colors.blue.shade900,
                Colors.black,
                Colors.blueAccent.shade700,
              ],
              stops: <double>[
                0.0,
                0.5 + 0.25 * sin(angle),
                1.0,
              ],
            ),
          ),
          child: child ?? widget.child,
        );
      },
      child: widget.child,
    );
  }
}
