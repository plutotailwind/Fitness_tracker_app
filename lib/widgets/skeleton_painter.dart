import 'package:flutter/material.dart';

/// Draws a simple human skeleton using normalized landmark coordinates (0..1)
/// Expected keys: nose, leftShoulder, rightShoulder, leftElbow, rightElbow,
/// leftWrist, rightWrist, leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle
class SkeletonPainter extends CustomPainter {
  final Map<String, Offset> landmarks; // normalized in [0,1]
  final Color lineColor;
  final double strokeWidth;

  SkeletonPainter({
    required this.landmarks,
    this.lineColor = Colors.limeAccent,
    this.strokeWidth = 3.0,
  });

  static const List<List<String>> _connections = [
    // Torso
    ['leftShoulder', 'rightShoulder'],
    ['leftHip', 'rightHip'],
    ['leftShoulder', 'leftHip'],
    ['rightShoulder', 'rightHip'],
    // Arms
    ['leftShoulder', 'leftElbow'],
    ['leftElbow', 'leftWrist'],
    ['rightShoulder', 'rightElbow'],
    ['rightElbow', 'rightWrist'],
    // Legs
    ['leftHip', 'leftKnee'],
    ['leftKnee', 'leftAnkle'],
    ['rightHip', 'rightKnee'],
    ['rightKnee', 'rightAnkle'],
    // Head/neck
    ['nose', 'leftShoulder'],
    ['nose', 'rightShoulder'],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset? _pt(String k) {
      final o = landmarks[k];
      if (o == null) return null;
      // Landmarks are normalized (x to width, y to height)
      return Offset(o.dx * size.width, o.dy * size.height);
    }

    for (final pair in _connections) {
      final a = _pt(pair[0]);
      final b = _pt(pair[1]);
      if (a == null || b == null) continue;
      canvas.drawLine(a, b, paint);
    }

    // Draw joints as small circles
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (final entry in landmarks.entries) {
      final p = _pt(entry.key);
      if (p == null) continue;
      canvas.drawCircle(p, 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}


