import 'package:flutter/material.dart';

class ResponsiveService {
  ResponsiveService._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool isWide(BuildContext context) => width(context) >= 720;

  static double horizontalPadding(BuildContext context) {
    final double w = width(context);
    if (w >= 1100) return 40;
    if (w >= 720) return 28;
    return 16;
  }

  static double fontSize(BuildContext context, double base) {
    final double w = width(context);
    final double scale = (w / 390).clamp(0.92, 1.18);
    return base * scale;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final double w = width(context);
    if (w >= 1100) return 3;
    if (w >= 680) return 2;
    return 1;
  }
}