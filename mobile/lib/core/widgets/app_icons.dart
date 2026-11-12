import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Custom vector brand logo matching SVG/AI_Daily_Helper_Icon.svg 1:1.
class AppBrandMark extends StatelessWidget {
  final double size;
  const AppBrandMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AppBrandMarkPainter(),
    );
  }
}

class _AppBrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s, s);

    final bubbleGlow = Paint()
      ..color = AppColors.logoSwoosh.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(25, 11, 47, 74), const Radius.circular(13)),
      bubbleGlow,
    );

    final navyStroke = Paint()
      ..color = AppColors.navyLogo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top-left bubble path: M25 68V24c0-8 5-13 13-13h32
    final topBubble = Path()
      ..moveTo(25, 68)
      ..lineTo(25, 24)
      ..quadraticBezierTo(25, 11, 38, 11)
      ..lineTo(70, 11);
    canvas.drawPath(topBubble, navyStroke);

    // Bottom-right bubble tail: M72 29v43c0 8-5 13-13 13H43l-13 9v-9
    final bottomBubble = Path()
      ..moveTo(72, 29)
      ..lineTo(72, 72)
      ..quadraticBezierTo(72, 85, 59, 85)
      ..lineTo(43, 85)
      ..lineTo(30, 94)
      ..lineTo(30, 85);
    canvas.drawPath(bottomBubble, navyStroke);

    // Checklist strokes inside bubble
    final innerStroke = Paint()
      ..color = AppColors.navyLogo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkAndLines = Path()
      ..moveTo(36, 42)
      ..lineTo(43, 49)
      ..lineTo(55, 36)
      ..moveTo(57, 48)
      ..lineTo(69, 48)
      ..moveTo(37, 63)
      ..lineTo(62, 63);
    canvas.drawPath(checkAndLines, innerStroke);

    // Swoosh: M10 74c22 10 64 0 81-27
    final swooshPaint = Paint()
      ..color = AppColors.logoSwoosh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.2
      ..strokeCap = StrokeCap.round;
    final swoosh = Path()
      ..moveTo(10, 74)
      ..cubicTo(32, 84, 74, 74, 91, 47);
    canvas.drawPath(swoosh, swooshPaint);

    // 4-point sparkle at (81, 7)
    final sparklePaint = Paint()
      ..color = AppColors.logoSwoosh
      ..style = PaintingStyle.fill;
    final sparkle = Path()
      ..moveTo(81, 7)
      ..lineTo(85, 16)
      ..lineTo(94, 20)
      ..lineTo(85, 24)
      ..lineTo(81, 33)
      ..lineTo(77, 24)
      ..lineTo(68, 20)
      ..lineTo(77, 16)
      ..close();
    canvas.drawPath(sparkle, sparklePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum AppIconType {
  chevronLeft,
  chevronRight,
  arrowRight,
  plus,
  moreDots,
  bell,
  calendar,
  checkCircle,
  mic,
  shoppingCart,
  brain,
  briefcase,
  heart,
  book,
  user,
  shieldCheck,
  sparkle,
  mail,
  lock,
  search,
  clock,
  editPen,
  bookmark,
  star,
  trash,
  settingsGear,
  wallet,
  refresh,
  pause,
  checkMark,
  noteLines,
  logOut,
}

/// Bold dual-tone rounded vector icons engineered for crisp readability at any scale.
class AppVectorIcon extends StatelessWidget {
  final AppIconType type;
  final double size;
  final Color color;
  final double strokeWidth;

  const AppVectorIcon(
    this.type, {
    super.key,
    this.size = 21,
    this.color = AppColors.navy,
    this.strokeWidth = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AppIconPainter(type: type, color: color, strokeWidth: strokeWidth),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  final AppIconType type;
  final Color color;
  final double strokeWidth;

  _AppIconPainter({required this.type, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final duotonePaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    switch (type) {
      case AppIconType.chevronLeft:
        canvas.drawPath(Path()..moveTo(15, 18)..lineTo(8.5, 12)..lineTo(15, 6), paint);
        break;
      case AppIconType.chevronRight:
        canvas.drawPath(Path()..moveTo(9, 18)..lineTo(15.5, 12)..lineTo(9, 6), paint);
        break;
      case AppIconType.arrowRight:
        canvas.drawPath(
          Path()..moveTo(5, 12)..lineTo(19, 12)..moveTo(13, 6)..lineTo(19, 12)..lineTo(13, 18),
          paint,
        );
        break;
      case AppIconType.plus:
        canvas.drawPath(Path()..moveTo(12, 4.5)..lineTo(12, 19.5)..moveTo(4.5, 12)..lineTo(19.5, 12), paint);
        break;
      case AppIconType.moreDots:
        canvas.drawCircle(const Offset(5, 12), 1.85, fillPaint);
        canvas.drawCircle(const Offset(12, 12), 1.85, fillPaint);
        canvas.drawCircle(const Offset(19, 12), 1.85, fillPaint);
        break;
      case AppIconType.bell:
        final bellBody = Path()
          ..moveTo(18, 8.5)
          ..arcToPoint(const Offset(6, 8.5), radius: const Radius.circular(6), clockwise: false)
          ..cubicTo(6, 15, 3, 15.5, 3, 17.5)
          ..lineTo(21, 17.5)
          ..cubicTo(21, 15.5, 18, 15, 18, 8.5)
          ..close();
        canvas.drawPath(bellBody, duotonePaint);
        canvas.drawPath(bellBody, paint);
        canvas.drawPath(Path()..moveTo(9.8, 21)..lineTo(14.2, 21), paint);
        break;
      case AppIconType.calendar:
        final box = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4.8, 18, 16.2), const Radius.circular(3.5));
        canvas.drawRRect(box, duotonePaint);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            const Rect.fromLTWH(3, 4.8, 18, 5.2),
            topLeft: const Radius.circular(3.5),
            topRight: const Radius.circular(3.5),
          ),
          duotonePaint,
        );
        canvas.drawRRect(box, paint);
        canvas.drawPath(
          Path()..moveTo(7.5, 2.8)..lineTo(7.5, 6.8)..moveTo(16.5, 2.8)..lineTo(16.5, 6.8)..moveTo(3, 10)..lineTo(21, 10),
          paint,
        );
        canvas.drawCircle(const Offset(8.5, 14.5), 1.35, fillPaint);
        canvas.drawCircle(const Offset(12, 14.5), 1.35, fillPaint);
        canvas.drawCircle(const Offset(15.5, 14.5), 1.35, fillPaint);
        break;
      case AppIconType.checkCircle:
        canvas.drawCircle(const Offset(12, 12), 9.2, duotonePaint);
        canvas.drawCircle(const Offset(12, 12), 9.2, paint);
        canvas.drawPath(Path()..moveTo(8.2, 12.2)..lineTo(11, 15)..lineTo(16.2, 9.2), paint);
        break;
      case AppIconType.mic:
        final capsule = RRect.fromRectAndRadius(const Rect.fromLTWH(8.8, 2.4, 6.4, 12.2), const Radius.circular(3.2));
        canvas.drawRRect(capsule, duotonePaint);
        canvas.drawRRect(capsule, paint);
        final arc = Path()
          ..moveTo(5, 10.5)
          ..arcToPoint(const Offset(19, 10.5), radius: const Radius.circular(7), clockwise: false)
          ..moveTo(12, 17.5)
          ..lineTo(12, 21.5)
          ..moveTo(8.2, 21.5)
          ..lineTo(15.8, 21.5);
        canvas.drawPath(arc, paint);
        break;
      case AppIconType.shoppingCart:
        final basketFill = Path()
          ..moveTo(5.5, 7)
          ..lineTo(21.5, 7)
          ..lineTo(19.8, 15.8)
          ..lineTo(7.2, 15.8)
          ..close();
        canvas.drawPath(basketFill, duotonePaint);
        canvas.drawCircle(const Offset(9, 20), 1.75, fillPaint);
        canvas.drawCircle(const Offset(18.5, 20), 1.75, fillPaint);
        canvas.drawPath(
          Path()..moveTo(2, 3.2)..lineTo(4.5, 3.2)..lineTo(7.2, 15.8)..lineTo(19.8, 15.8)..lineTo(21.8, 7)..lineTo(5.2, 7),
          paint,
        );
        break;
      case AppIconType.brain:
        final brainBody = Path()
          ..moveTo(12, 5.5)
          ..arcToPoint(const Offset(5, 8), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(4, 15), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(11, 18.5), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(12, 18.5)
          ..arcToPoint(const Offset(20, 15), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(19, 8), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(12, 5.5), radius: const Radius.circular(4), clockwise: false)
          ..close();
        canvas.drawPath(brainBody, duotonePaint);
        final brain = Path()
          ..moveTo(12, 5.5)
          ..arcToPoint(const Offset(5, 8), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(4, 15), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(11, 18.5), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(12, 18.5)
          ..lineTo(12, 5.5)
          ..arcToPoint(const Offset(19, 8), radius: const Radius.circular(4), clockwise: true)
          ..arcToPoint(const Offset(20, 15), radius: const Radius.circular(4), clockwise: true)
          ..arcToPoint(const Offset(13, 18.5), radius: const Radius.circular(4), clockwise: true)
          ..lineTo(12, 18.5)
          ..moveTo(8, 9.5)
          ..lineTo(8, 15)
          ..moveTo(16, 9.5)
          ..lineTo(16, 15);
        canvas.drawPath(brain, paint);
        break;
      case AppIconType.briefcase:
        final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 7, 18, 14), const Radius.circular(3));
        canvas.drawRRect(rect, duotonePaint);
        canvas.drawRRect(rect, paint);
        canvas.drawPath(
          Path()..moveTo(8.5, 7)..lineTo(8.5, 4)..lineTo(15.5, 4)..lineTo(15.5, 7)..moveTo(3, 13)..lineTo(21, 13),
          paint,
        );
        canvas.drawCircle(const Offset(12, 13), 1.3, fillPaint);
        break;
      case AppIconType.heart:
        final heart = Path()
          ..moveTo(12, 21)
          ..cubicTo(12, 21, 3.8, 15, 3.8, 9.2)
          ..cubicTo(3.8, 6, 6.2, 3.8, 9, 3.8)
          ..cubicTo(10.8, 3.8, 12, 5, 12, 6.2)
          ..cubicTo(12, 5, 13.2, 3.8, 15, 3.8)
          ..cubicTo(17.8, 3.8, 20.2, 6, 20.2, 9.2)
          ..cubicTo(20.2, 15, 12, 21, 12, 21)
          ..close();
        canvas.drawPath(heart, duotonePaint);
        canvas.drawPath(heart, paint);
        break;
      case AppIconType.book:
        final book = Path()
          ..moveTo(12, 6)
          ..quadraticBezierTo(7.5, 4, 3, 5.2)
          ..lineTo(3, 19.8)
          ..quadraticBezierTo(7.5, 18.6, 12, 20.8)
          ..quadraticBezierTo(16.5, 18.6, 21, 19.8)
          ..lineTo(21, 5.2)
          ..quadraticBezierTo(16.5, 4, 12, 6)
          ..close();
        canvas.drawPath(book, duotonePaint);
        canvas.drawPath(
          Path()..addPath(book, Offset.zero)..moveTo(12, 6)..lineTo(12, 20.8),
          paint,
        );
        break;
      case AppIconType.user:
        canvas.drawCircle(const Offset(12, 7.8), 4.2, duotonePaint);
        canvas.drawCircle(const Offset(12, 7.8), 4.2, paint);
        final shoulders = Path()..moveTo(4, 21)..cubicTo(4, 15.6, 20, 15.6, 20, 21)..close();
        canvas.drawPath(shoulders, duotonePaint);
        canvas.drawPath(
          Path()..moveTo(4, 21)..cubicTo(4, 15.6, 20, 15.6, 20, 21),
          paint,
        );
        break;
      case AppIconType.shieldCheck:
        final shield = Path()
          ..moveTo(12, 2.2)
          ..lineTo(20.8, 5.8)
          ..lineTo(20.8, 12)
          ..cubicTo(20.8, 17, 16.8, 20.2, 12, 22)
          ..cubicTo(7.2, 20.2, 3.2, 17, 3.2, 12)
          ..lineTo(3.2, 5.8)
          ..close();
        canvas.drawPath(shield, duotonePaint);
        canvas.drawPath(shield, paint);
        canvas.drawPath(Path()..moveTo(8.2, 12)..lineTo(11, 14.8)..lineTo(16, 9), paint);
        break;
      case AppIconType.sparkle:
        final sp = Path()
          ..moveTo(12, 2.2)
          ..lineTo(14.7, 9.3)
          ..lineTo(21.8, 12)
          ..lineTo(14.7, 14.7)
          ..lineTo(12, 21.8)
          ..lineTo(9.3, 14.7)
          ..lineTo(2.2, 12)
          ..lineTo(9.3, 9.3)
          ..close();
        canvas.drawPath(sp, Paint()..color = color.withValues(alpha: 0.28)..style = PaintingStyle.fill);
        canvas.drawPath(sp, paint);
        canvas.drawCircle(const Offset(19, 5), 1.25, fillPaint);
        break;
      case AppIconType.mail:
        final env = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 5, 18, 14), const Radius.circular(3));
        canvas.drawRRect(env, duotonePaint);
        canvas.drawRRect(env, paint);
        canvas.drawPath(Path()..moveTo(3.5, 7)..lineTo(12, 13.8)..lineTo(20.5, 7), paint);
        break;
      case AppIconType.lock:
        final body = RRect.fromRectAndRadius(const Rect.fromLTWH(5, 10, 14, 11), const Radius.circular(3));
        canvas.drawRRect(body, duotonePaint);
        canvas.drawRRect(body, paint);
        canvas.drawPath(
          Path()
            ..moveTo(8, 10)
            ..lineTo(8, 7)
            ..arcToPoint(const Offset(16, 7), radius: const Radius.circular(4), clockwise: true)
            ..lineTo(16, 10),
          paint,
        );
        canvas.drawCircle(const Offset(12, 15.5), 1.4, fillPaint);
        break;
      case AppIconType.search:
        canvas.drawCircle(const Offset(10.8, 10.8), 7, duotonePaint);
        canvas.drawCircle(const Offset(10.8, 10.8), 7, paint);
        canvas.drawPath(Path()..moveTo(16, 16)..lineTo(21, 21), paint);
        break;
      case AppIconType.clock:
        canvas.drawCircle(const Offset(12, 12), 9.2, duotonePaint);
        canvas.drawCircle(const Offset(12, 12), 9.2, paint);
        canvas.drawPath(Path()..moveTo(12, 6.5)..lineTo(12, 12)..lineTo(16, 14), paint);
        canvas.drawCircle(const Offset(12, 12), 1.3, fillPaint);
        break;
      case AppIconType.editPen:
        final pen = Path()
          ..moveTo(4, 20)
          ..lineTo(8.5, 19)
          ..lineTo(20, 7.5)
          ..lineTo(16.5, 4)
          ..lineTo(5, 15.5)
          ..close();
        canvas.drawPath(pen, duotonePaint);
        canvas.drawPath(
          Path()..addPath(pen, Offset.zero)..moveTo(14.5, 6)..lineTo(18, 9.5),
          paint,
        );
        break;
      case AppIconType.bookmark:
        final bm = Path()
          ..moveTo(6, 3.2)
          ..lineTo(18, 3.2)
          ..lineTo(18, 20.8)
          ..lineTo(12, 16.5)
          ..lineTo(6, 20.8)
          ..close();
        canvas.drawPath(bm, duotonePaint);
        canvas.drawPath(bm, paint);
        break;
      case AppIconType.star:
        final star = Path()
          ..moveTo(12, 2.2)
          ..lineTo(15.1, 8.3)
          ..lineTo(21.8, 9.3)
          ..lineTo(17, 14.2)
          ..lineTo(18.2, 21)
          ..lineTo(12, 17.8)
          ..lineTo(5.8, 21)
          ..lineTo(7, 14.2)
          ..lineTo(2.2, 9.3)
          ..lineTo(8.9, 8.3)
          ..close();
        canvas.drawPath(star, duotonePaint);
        canvas.drawPath(star, paint);
        break;
      case AppIconType.trash:
        final bucket = Path()
          ..moveTo(6.2, 7)
          ..lineTo(7.2, 20.8)
          ..lineTo(16.8, 20.8)
          ..lineTo(17.8, 7)
          ..close();
        canvas.drawPath(bucket, duotonePaint);
        canvas.drawPath(
          Path()
            ..moveTo(4, 7)
            ..lineTo(20, 7)
            ..moveTo(9, 7)
            ..lineTo(9, 4)
            ..lineTo(15, 4)
            ..lineTo(15, 7)
            ..moveTo(6.2, 7)
            ..lineTo(7.2, 20.8)
            ..lineTo(16.8, 20.8)
            ..lineTo(17.8, 7)
            ..moveTo(10.2, 11)
            ..lineTo(10.2, 17.5)
            ..moveTo(13.8, 11)
            ..lineTo(13.8, 17.5),
          paint,
        );
        break;
      case AppIconType.settingsGear:
        final gear = Path();
        const teeth = 8;
        for (int i = 0; i < teeth * 2; i++) {
          final r = i.isEven ? 9.8 : 7.3;
          final a = (i * math.pi / teeth) - math.pi / 2;
          final x = 12 + r * math.cos(a);
          final y = 12 + r * math.sin(a);
          if (i == 0) {
            gear.moveTo(x, y);
          } else {
            gear.lineTo(x, y);
          }
        }
        gear.close();
        canvas.drawPath(gear, duotonePaint);
        canvas.drawPath(gear, paint);
        canvas.drawCircle(const Offset(12, 12), 3.1, Paint()..color = color.withValues(alpha: 0.12));
        canvas.drawCircle(const Offset(12, 12), 3.1, paint);
        break;
      case AppIconType.wallet:
        final wal = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 6, 18, 15), const Radius.circular(3.5));
        canvas.drawRRect(wal, duotonePaint);
        canvas.drawRRect(wal, paint);
        canvas.drawPath(
          Path()
            ..moveTo(3, 10.2)
            ..lineTo(21, 10.2)
            ..moveTo(6.5, 6)
            ..lineTo(6.5, 3.8)
            ..lineTo(17.5, 3.8),
          paint,
        );
        canvas.drawCircle(const Offset(16.8, 15.2), 1.5, fillPaint);
        break;
      case AppIconType.refresh:
        canvas.drawPath(
          Path()
            ..moveTo(4, 8)
            ..arcToPoint(const Offset(17, 5), radius: const Radius.circular(8), clockwise: true)
            ..lineTo(19, 7)
            ..moveTo(19, 3)
            ..lineTo(19, 7)
            ..lineTo(15, 7)
            ..moveTo(20, 16)
            ..arcToPoint(const Offset(7, 19), radius: const Radius.circular(8), clockwise: true)
            ..lineTo(5, 17)
            ..moveTo(5, 21)
            ..lineTo(5, 17)
            ..lineTo(9, 17),
          paint,
        );
        break;
      case AppIconType.pause:
        canvas.drawPath(
          Path()..moveTo(8, 5)..lineTo(8, 19)..moveTo(16, 5)..lineTo(16, 19),
          paint..strokeWidth = strokeWidth + 0.6,
        );
        break;
      case AppIconType.checkMark:
        canvas.drawPath(
          Path()..moveTo(5, 12.5)..lineTo(9.2, 16.8)..lineTo(19.2, 6.2),
          paint..strokeWidth = strokeWidth + 0.3,
        );
        break;
      case AppIconType.noteLines:
        final note = RRect.fromRectAndRadius(const Rect.fromLTWH(4, 3, 16, 18), const Radius.circular(3));
        canvas.drawRRect(note, duotonePaint);
        canvas.drawRRect(note, paint);
        canvas.drawPath(
          Path()..moveTo(8, 9)..lineTo(16, 9)..moveTo(8, 13)..lineTo(16, 13)..moveTo(8, 17)..lineTo(12.5, 17),
          paint,
        );
        break;
      case AppIconType.logOut:
        final door = RRect.fromRectAndRadius(const Rect.fromLTWH(3.5, 3.5, 9.5, 17), const Radius.circular(3));
        canvas.drawRRect(door, duotonePaint);
        canvas.drawPath(
          Path()
            ..moveTo(11, 3.8)
            ..lineTo(6.2, 3.8)
            ..quadraticBezierTo(3.8, 3.8, 3.8, 6.2)
            ..lineTo(3.8, 17.8)
            ..quadraticBezierTo(3.8, 20.2, 6.2, 20.2)
            ..lineTo(11, 20.2)
            ..moveTo(10, 12)
            ..lineTo(20.5, 12)
            ..moveTo(16.2, 7.8)
            ..lineTo(20.5, 12)
            ..lineTo(16.2, 16.2),
          paint,
        );
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AppIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
