import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// DiyaPainter renders a divine decorative Diya (lamp flame) symbol.
class DiyaPainter extends CustomPainter {
  final Color color;

  DiyaPainter({this.color = AppColors.deepSaffron});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Paint Diya base (bowl)
    final bowlPaint = Paint()
      ..color = AppColors.warmGold
      ..style = PaintingStyle.fill;

    final bowlPath = Path()
      ..moveTo(width * 0.2, height * 0.6)
      ..cubicTo(
        width * 0.3,
        height * 0.9,
        width * 0.7,
        height * 0.9,
        width * 0.8,
        height * 0.6,
      )
      ..lineTo(width * 0.75, height * 0.6)
      ..cubicTo(
        width * 0.65,
        height * 0.8,
        width * 0.35,
        height * 0.8,
        width * 0.25,
        height * 0.6,
      )
      ..close();

    canvas.drawPath(bowlPath, bowlPaint);

    // Paint Diya Flame
    final flamePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.shade300,
          color,
          AppColors.sacredRed,
        ],
        stops: const [0.2, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.65));

    final flamePath = Path()
      ..moveTo(width / 2, height * 0.05)
      ..cubicTo(
        width * 0.75,
        height * 0.35,
        width * 0.65,
        height * 0.62,
        width / 2,
        height * 0.65,
      )
      ..cubicTo(
        width * 0.35,
        height * 0.62,
        width * 0.25,
        height * 0.35,
        width / 2,
        height * 0.05,
      )
      ..close();

    canvas.drawPath(flamePath, flamePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// DiyaWidget embeds the CustomPainter as a scalable icon or graphic.
class DiyaWidget extends StatelessWidget {
  final double size;
  final Color color;

  const DiyaWidget({
    super.key,
    this.size = 36.0,
    this.color = AppColors.deepSaffron,
  });

  @override
  Widget build(BuildContext context) {
    return
      
      SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DiyaPainter(color: color),
      ),
    );
  }
}

/// SacredDivider renders a manuscript-inspired decorative gold divider.
class SacredDivider extends StatelessWidget {
  const SacredDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warmGold.withValues(alpha: 0.0),
                    AppColors.warmGold.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: DiyaWidget(size: 20),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warmGold.withValues(alpha: 0.6),
                    AppColors.warmGold.withValues(alpha: 0.0),
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
