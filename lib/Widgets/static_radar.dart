// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import 'package:zero_share/utils/color.dart';

class RadarWidget extends StatelessWidget {
  final double size; // Size of the radar widget
  final Color radarColor; // Color of the radar circles
  final Widget?
      centerChild; // Widget to display in the center (e.g., icon or text)
  final Function onTap;
  const RadarWidget({
    super.key,
    this.size = 200.0,
    this.radarColor = AppColor.primary,
    this.centerChild,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: RadarPainter(radarColor: radarColor),
          ),
          GestureDetector(
            onTap: () {
              debugPrint('Tap to Scan');
              onTap();
            },
            child: centerChild ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, size: 40, color: radarColor),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to Scan',
                      style: TextStyle(
                        color: radarColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Color radarColor;

  RadarPainter({required this.radarColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = radarColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0;

    final double maxRadius = size.width / 2;

    // Draw static radar circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        maxRadius * i / 4,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint since it's static
  }
}
