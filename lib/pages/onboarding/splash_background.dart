import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: SplashBackgroundPainter(),
    );
  }
}

class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEAF6FF),
          Color(0xFFF9FDFF),
          Color(0xFFE6F7FF),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Top light-blue curve
    final topPaint = Paint()
      ..color = const Color(0xFFDDF3FF);

    final topPath = Path();

    topPath.moveTo(0, 0);
    topPath.lineTo(size.width, 0);

    topPath.cubicTo(
      size.width * 0.82,
      size.height * 0.12,
      size.width * 0.68,
      size.height * 0.22,
      size.width * 0.35,
      size.height * 0.30,
    );

    topPath.cubicTo(
      size.width * 0.18,
      size.height * 0.34,
      size.width * 0.08,
      size.height * 0.37,
      0,
      size.height * 0.40,
    );

    topPath.close();

    canvas.drawPath(topPath, topPaint);

    // Middle wave
    final middlePaint = Paint()
      ..color = const Color(0xFFB9E9FF);

    final middlePath = Path();

    middlePath.moveTo(0, size.height * 0.78);

    middlePath.cubicTo(
      size.width * 0.18,
      size.height * 0.86,
      size.width * 0.32,
      size.height * 0.91,
      size.width * 0.48,
      size.height * 0.87,
    );

    middlePath.cubicTo(
      size.width * 0.66,
      size.height * 0.82,
      size.width * 0.78,
      size.height * 0.72,
      size.width,
      size.height * 0.68,
    );

    middlePath.lineTo(size.width, size.height);
    middlePath.lineTo(0, size.height);
    middlePath.close();

    canvas.drawPath(middlePath, middlePaint);

    // Front blue wave
    final frontPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF36B5F2),
          Color(0xFF19AEEB),
          Color(0xFF24C5D8),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * 0.72,
          size.width,
          size.height * 0.28,
        ),
      );

    final frontPath = Path();

    frontPath.moveTo(0, size.height * 0.82);

    frontPath.cubicTo(
      size.width * 0.20,
      size.height * 0.94,
      size.width * 0.34,
      size.height * 0.99,
      size.width * 0.50,
      size.height * 0.94,
    );

    frontPath.cubicTo(
      size.width * 0.68,
      size.height * 0.88,
      size.width * 0.82,
      size.height * 0.76,
      size.width,
      size.height * 0.72,
    );

    frontPath.lineTo(size.width, size.height);
    frontPath.lineTo(0, size.height);
    frontPath.close();

    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}