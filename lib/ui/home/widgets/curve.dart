import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'dart:math'as math;

class CurvePainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    Paint rectPaint = Paint()
      ..color = Colors.grey
      ..blendMode = BlendMode.darken
      ..style = PaintingStyle.fill;
var radius=20;

    for (double angle = 180; angle >= 0; angle = angle - 6) {
      double angleInRadians = angle * math.pi / 180;

      double x = radius * math.cos(angleInRadians);
      double y = radius * math.sin(angleInRadians);
      y -= radius;
      y = -y;
      x += size.width / 2;
      canvas.save();
      canvas.translate(x, y + 27);
      canvas.rotate(-angleInRadians);
      canvas.drawRect(
          Rect.fromCenter(height: 4, width: 16, center: Offset(0, 0)),
          rectPaint);
      canvas.restore();
    }
    paint.color = Colors.lightBlue;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;


    canvas.drawPaint(
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
class CurvePainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    path.lineTo(0.0, size.height / 1);
    path.lineTo(size.width, size.height / 1);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}