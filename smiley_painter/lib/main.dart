// In-Class Activity 06 — Drawing with Flutter
// Student: Marquez Johnson
// Date: September 30, 2026

import 'dart:math' show pi, Random;
import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType { classic, sleepy, surprised }

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  double mood = 0.8; // 0.0 sad → 1.0 happy
  FaceType faceType = FaceType.classic;

  Color _getFaceColor(double moodValue) {
    if (moodValue < 0.35) {
      return Colors.lightBlue.shade300;
    } else if (moodValue <= 0.7) {
      return Colors.amber.shade400;
    } else {
      return Colors.orangeAccent.shade200;
    }
  }

  void _cycleFace() {
    setState(() {
      final nextIndex = (faceType.index + 1) % FaceType.values.length;
      faceType = FaceType.values[nextIndex];
    });
    _showFeedback('Switched to ${faceType.name.toUpperCase()} mode');
  }

  void _randomizeMood() {
    final random = Random();
    setState(() {
      mood = double.parse(random.nextDouble().toStringAsFixed(2));
    });
    _showFeedback('Randomized mood to $mood');
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faceColor = _getFaceColor(mood);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SegmentedButton<FaceType>(
                segments: const [
                  ButtonSegment(value: FaceType.classic, label: Text('Classic')),
                  ButtonSegment(value: FaceType.sleepy, label: Text('Sleepy')),
                  ButtonSegment(value: FaceType.surprised, label: Text('Surprised')),
                ],
                selected: {faceType},
                onSelectionChanged: (newSelection) {
                  setState(() => faceType = newSelection.first);
                },
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _cycleFace,
                  onLongPress: _randomizeMood,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: SmileyPainter(
                      mood: mood,
                      faceColor: faceColor,
                      faceType: faceType,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Mood: ${mood.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Slider(
                    value: mood,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (double v) => setState(() => mood = v),
                  ),
                  const Text(
                    'Tap face to cycle type • Long-press to randomize',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  final double mood;
  final Color faceColor;
  final FaceType faceType;

  SmileyPainter({
    required this.mood,
    required this.faceColor,
    required this.faceType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.40;

    // 1. Face Circle
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // 2. Face Border
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, borderPaint);

    // 3. Eyes
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeDx = radius * 0.35;
    final eyeDy = radius * 0.22;
    final leftEyeCenter = Offset(center.dx - eyeDx, center.dy - eyeDy);
    final rightEyeCenter = Offset(center.dx + eyeDx, center.dy - eyeDy);

    if (faceType == FaceType.sleepy) {
      final sleepyEyePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5;

      final eyeArcRectLeft = Rect.fromCircle(center: leftEyeCenter, radius: radius * 0.14);
      final eyeArcRectRight = Rect.fromCircle(center: rightEyeCenter, radius: radius * 0.14);

      canvas.drawArc(eyeArcRectLeft, 0.2 * pi, 0.6 * pi, false, sleepyEyePaint);
      canvas.drawArc(eyeArcRectRight, 0.2 * pi, 0.6 * pi, false, sleepyEyePaint);
    } else {
      final eyeRadius = (faceType == FaceType.surprised) ? radius * 0.18 : radius * 0.12;
      canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, eyePaint);
    }

    // 4. Mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    if (faceType == FaceType.surprised) {
      final mouthCenter = Offset(center.dx, center.dy + (radius * 0.38));
      final surprisedMouthPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: mouthCenter,
          width: radius * 0.32,
          height: radius * (0.30 + (mood * 0.30)),
        ),
        surprisedMouthPaint,
      );
    } else {
      final mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + (radius * 0.20)),
        width: radius * 1.1,
        height: radius * 0.85,
      );

      double startAngle;
      double sweepAngle;

      if (mood >= 0.5) {
        // Smile: curves downward along bottom half
        startAngle = 0.15 * pi;
        sweepAngle = (0.2 + (mood - 0.5) * 1.0) * pi;
      } else {
        // Frown: curves along top half
        startAngle = 1.15 * pi;
        sweepAngle = (0.70 - (mood * 0.8)) * pi;
      }

      canvas.drawArc(mouthRect, startAngle, sweepAngle, false, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.faceType != faceType;
  }
}


/*For the proportions and responsiveness, instead of using fixed pixels, all the coordinates scale from size.shortestSide * 0.40 for the face radius and the eye placement and mouth dimensions are defined as fractions of that radius which allows the entire face to adapt automatically to any screen size without overflow or clipping.

The repaint behavior, where shouldRepaint checks whether mood, faceColor, or faceType actually changed before requesting a redraw. Returning false when values are unchanged helps prevent unnecessary canvas rending while returning true would waste resources on every single frame rebuild. 
/*