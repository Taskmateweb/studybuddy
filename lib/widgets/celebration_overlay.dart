import 'package:flutter/material.dart';
import 'dart:math' as math;

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Confetti> _confetti = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Generate confetti particles
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _confetti.add(
        Confetti(
          color: _getRandomColor(random),
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.3,
          random: random,
        ),
      );
    }

    _controller.forward();

    // Auto close after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      const Color(0xFF667EEA),
      const Color(0xFF764BA2),
      const Color(0xFFF093FB),
      const Color(0xFF4FACFE),
      const Color(0xFF00BCD4),
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.yellow,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent background
          Container(color: Colors.black12),
          
          // Confetti
          ..._confetti.map((confetti) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = (_controller.value - confetti.delay).clamp(0.0, 1.0);
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;

                // Calculate position
                final yPosition = progress * screenHeight * 1.2;
                final xPosition = confetti.x * screenWidth +
                    math.sin(progress * math.pi * 4) * 30;

                // Fade out at the end
                final opacity = progress < 0.8 ? 1.0 : (1.0 - progress) / 0.2;

                return Positioned(
                  left: xPosition,
                  top: yPosition,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: progress * math.pi * 4,
                      child: Container(
                        width: 8,
                        height: 12,
                        decoration: BoxDecoration(
                          color: confetti.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Center celebration icon
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
            ),
          ),

          // Success text
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _controller,
              child: const Text(
                '🎉 Task Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Confetti {
  final Color color;
  final double x;
  final double delay;
  final math.Random random;

  Confetti({
    required this.color,
    required this.x,
    required this.delay,
    required this.random,
  });
}
