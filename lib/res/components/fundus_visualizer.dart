import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';

class FundusVisualizer extends StatelessWidget {
  final String imagePath;
  final List<DetectionPoint> detectionPoints;
  final bool showGradCam;
  final double height;

  const FundusVisualizer({
    super.key,
    required this.imagePath,
    required this.detectionPoints,
    this.showGradCam = false,
    this.height = 240,
  });

  bool get _hasValidLocalFile {
    if (imagePath.isEmpty || imagePath.startsWith('sample://')) return false;
    try {
      return File(imagePath).existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFF070D17),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (_hasValidLocalFile)
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              )
            else
              CustomPaint(
                painter: _ProceduralFundusPainter(
                  variantKey: imagePath,
                  detectionPoints: detectionPoints,
                ),
              ),
            if (showGradCam)
              CustomPaint(
                painter: _GradCamOverlayPainter(
                  detectionPoints: detectionPoints,
                ),
              ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withAlpha(210),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: showGradCam ? AppColors.accentMint : AppColors.borderLight.withAlpha(80),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      showGradCam ? Icons.gradient_rounded : Icons.remove_red_eye_outlined,
                      color: showGradCam ? AppColors.accentMint : AppColors.surfaceWhite,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      showGradCam ? 'Grad-CAM AI Attention Map' : 'Original Retinal Fundus',
                      style: const TextStyle(
                        color: AppColors.surfaceWhite,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProceduralFundusPainter extends CustomPainter {
  final String variantKey;
  final List<DetectionPoint> detectionPoints;

  _ProceduralFundusPainter({
    required this.variantKey,
    required this.detectionPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.5, size.height * 0.5);
    final double radius = size.shortestSide * 0.44;

    final Paint bgPaint = Paint()..color = const Color(0xFF060A12);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final Paint retinaPaint = Paint()
      ..shader = RadialGradient(
        colors: const <Color>[
          Color(0xFFC84B31),
          Color(0xFF8E2419),
          Color(0xFF47100B),
        ],
        stops: const <double>[0.15, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, retinaPaint);

    final Offset opticDisc = Offset(
      center.dx - radius * 0.42,
      center.dy - radius * 0.04,
    );
    final Paint discPaint = Paint()
      ..shader = RadialGradient(
        colors: const <Color>[
          Color(0xFFFFE5B4),
          Color(0xFFF6B97A),
          Color(0xFFD96B43),
        ],
      ).createShader(Rect.fromCircle(center: opticDisc, radius: radius * 0.16));
    canvas.drawCircle(opticDisc, radius * 0.15, discPaint);

    final Paint vesselPaint = Paint()
      ..color = const Color(0xFF5A0E09).withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final Path upperArcade = Path()
      ..moveTo(opticDisc.dx, opticDisc.dy)
      ..quadraticBezierTo(
        center.dx - radius * 0.05,
        center.dy - radius * 0.58,
        center.dx + radius * 0.58,
        center.dy - radius * 0.25,
      );
    final Path lowerArcade = Path()
      ..moveTo(opticDisc.dx, opticDisc.dy)
      ..quadraticBezierTo(
        center.dx - radius * 0.05,
        center.dy + radius * 0.58,
        center.dx + radius * 0.58,
        center.dy + radius * 0.25,
      );
    final Path nasalBranch = Path()
      ..moveTo(opticDisc.dx, opticDisc.dy)
      ..quadraticBezierTo(
        opticDisc.dx - radius * 0.25,
        opticDisc.dy - radius * 0.30,
        opticDisc.dx - radius * 0.44,
        opticDisc.dy - radius * 0.48,
      );

    canvas.drawPath(upperArcade, vesselPaint);
    canvas.drawPath(lowerArcade, vesselPaint);
    canvas.drawPath(nasalBranch, vesselPaint);

    final Offset macula = Offset(center.dx + radius * 0.14, center.dy + radius * 0.03);
    final Paint maculaPaint = Paint()
      ..color = const Color(0xFF5E140D).withAlpha(115);
    canvas.drawCircle(macula, radius * 0.14, maculaPaint);

    final Paint lesionPaint = Paint()..color = const Color(0xFFFFD166).withAlpha(210);
    for (final DetectionPoint point in detectionPoints) {
      if (!point.label.toLowerCase().contains('optic')) {
        final Offset pos = Offset(
          size.width * point.xRatio,
          size.height * point.yRatio,
        );
        canvas.drawCircle(pos, 3.8, lesionPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralFundusPainter oldDelegate) {
    return oldDelegate.variantKey != variantKey ||
        oldDelegate.detectionPoints != detectionPoints;
  }
}

class _GradCamOverlayPainter extends CustomPainter {
  final List<DetectionPoint> detectionPoints;

  _GradCamOverlayPainter({required this.detectionPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint washPaint = Paint()
      ..color = const Color(0xFF0A2463).withAlpha(90);
    canvas.drawRect(Offset.zero & size, washPaint);

    for (final DetectionPoint point in detectionPoints) {
      final Offset pos = Offset(
        size.width * point.xRatio,
        size.height * point.yRatio,
      );
      final double heatRadius = size.shortestSide * 0.24;

      final Paint heatPaint = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFFFF1E00).withAlpha(210),
            const Color(0xFFFF9F1C).withAlpha(165),
            const Color(0xFF2EC4B6).withAlpha(95),
            const Color(0xFF0A2463).withAlpha(0),
          ],
          stops: const <double>[0.0, 0.35, 0.70, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: heatRadius));

      canvas.drawCircle(pos, heatRadius, heatPaint);

      final Paint ringPaint = Paint()
        ..color = AppColors.surfaceWhite.withAlpha(220)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(pos, 12, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradCamOverlayPainter oldDelegate) {
    return oldDelegate.detectionPoints != detectionPoints;
  }
}