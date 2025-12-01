import 'dart:math';
import 'package:flutter/material.dart';

class FallingStarsBackground extends StatefulWidget {
  const FallingStarsBackground({super.key});

  @override
  State<FallingStarsBackground> createState() => _FallingStarsBackgroundState();
}

class _FallingStarsBackgroundState extends State<FallingStarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  List<_Star> stars = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // generate banyak bintang
    for (int i = 0; i < 40; i++) {
      stars.add(_Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 1,
        speed: _random.nextDouble() * 0.002 + 0.0005,
      ));
    }
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
      builder: (_, __) {
        return CustomPaint(
          painter: _StarPainter(stars),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  double x;
  double y;
  double size;
  double speed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final Paint starPaint = Paint()..color = Colors.white;

  _StarPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        starPaint,
      );

      // update posisi (jatuh ke bawah)
      star.y += star.speed;
      if (star.y > 1) {
        star.y = 0;
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
