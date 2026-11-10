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

    final navyStroke = Paint()
      ..color = AppColors.navyLogo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
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
      ..strokeWidth = 6
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
      ..strokeWidth = 7
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
}

/// Crisp 1.8px rounded stroke icons matching every SVG in the HTML designs.
class AppVectorIcon extends StatelessWidget {
  final AppIconType type;
  final double size;
  final Color color;
  final double strokeWidth;

  const AppVectorIcon(
    this.type, {
    super.key,
    this.size = 20,
    this.color = AppColors.navy,
    this.strokeWidth = 1.8,
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

    switch (type) {
      case AppIconType.chevronLeft:
        canvas.drawPath(Path()..moveTo(15, 18)..lineTo(9, 12)..lineTo(15, 6), paint);
        break;
      case AppIconType.chevronRight:
        canvas.drawPath(Path()..moveTo(9, 18)..lineTo(15, 12)..lineTo(9, 6), paint);
        break;
      case AppIconType.arrowRight:
        canvas.drawPath(
          Path()..moveTo(5, 12)..lineTo(19, 12)..moveTo(13, 6)..lineTo(19, 12)..lineTo(13, 18),
          paint,
        );
        break;
      case AppIconType.plus:
        canvas.drawPath(Path()..moveTo(12, 5)..lineTo(12, 19)..moveTo(5, 12)..lineTo(19, 12), paint);
        break;
      case AppIconType.moreDots:
        canvas.drawCircle(const Offset(5, 12), 1.2, fillPaint);
        canvas.drawCircle(const Offset(12, 12), 1.2, fillPaint);
        canvas.drawCircle(const Offset(19, 12), 1.2, fillPaint);
        break;
      case AppIconType.bell:
        final bell = Path()
          ..moveTo(18, 8)
          ..arcToPoint(const Offset(6, 8), radius: const Radius.circular(6), clockwise: false)
          ..cubicTo(6, 15, 3, 15, 3, 17)
          ..lineTo(21, 17)
          ..cubicTo(21, 15, 18, 15, 18, 8)
          ..moveTo(10, 21)
          ..lineTo(14, 21);
        canvas.drawPath(bell, paint);
        break;
      case AppIconType.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3, 5, 18, 16), const Radius.circular(2)),
          paint,
        );
        canvas.drawPath(
          Path()..moveTo(7, 3)..lineTo(7, 7)..moveTo(17, 3)..lineTo(17, 7)..moveTo(3, 10)..lineTo(21, 10),
          paint,
        );
        break;
      case AppIconType.checkCircle:
        canvas.drawCircle(const Offset(12, 12), 9, paint);
        canvas.drawPath(Path()..moveTo(8, 12)..lineTo(11, 15)..lineTo(16, 9), paint);
        break;
      case AppIconType.mic:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(9, 2, 6, 13), const Radius.circular(3)),
          paint,
        );
        final arc = Path()
          ..moveTo(5, 10)
          ..arcToPoint(const Offset(19, 10), radius: const Radius.circular(7), clockwise: false)
          ..moveTo(12, 17)
          ..lineTo(12, 22)
          ..moveTo(8, 22)
          ..lineTo(16, 22);
        canvas.drawPath(arc, paint);
        break;
      case AppIconType.shoppingCart:
        canvas.drawCircle(const Offset(9, 20), 1.2, fillPaint);
        canvas.drawCircle(const Offset(19, 20), 1.2, fillPaint);
        canvas.drawPath(
          Path()..moveTo(2, 3)..lineTo(4, 3)..lineTo(7, 16)..lineTo(20, 16)..lineTo(22, 7)..lineTo(5, 7),
          paint,
        );
        break;
      case AppIconType.brain:
        final brain = Path()
          ..moveTo(12, 6)
          ..arcToPoint(const Offset(5, 8), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(4, 15), radius: const Radius.circular(4), clockwise: false)
          ..arcToPoint(const Offset(11, 18), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(12, 18)
          ..lineTo(12, 6)
          ..arcToPoint(const Offset(19, 8), radius: const Radius.circular(4), clockwise: true)
          ..arcToPoint(const Offset(20, 15), radius: const Radius.circular(4), clockwise: true)
          ..arcToPoint(const Offset(13, 18), radius: const Radius.circular(4), clockwise: true)
          ..lineTo(12, 18)
          ..moveTo(8, 9)
          ..lineTo(8, 15)
          ..moveTo(16, 9)
          ..lineTo(16, 15);
        canvas.drawPath(brain, paint);
        break;
      case AppIconType.briefcase:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3, 7, 18, 14), const Radius.circular(2)),
          paint,
        );
        canvas.drawPath(
          Path()..moveTo(8, 7)..lineTo(8, 4)..lineTo(16, 4)..lineTo(16, 7)..moveTo(3, 13)..lineTo(21, 13),
          paint,
        );
        break;
      case AppIconType.heart:
        final heart = Path()
          ..moveTo(12, 21)
          ..cubicTo(12, 21, 4, 15, 4, 9.2)
          ..cubicTo(4, 6.2, 6.4, 4, 9.2, 4)
          ..cubicTo(10.9, 4, 12, 5.1, 12, 6.2)
          ..cubicTo(12, 5.1, 13.1, 4, 14.8, 4)
          ..cubicTo(17.6, 4, 20, 6.2, 20, 9.2)
          ..cubicTo(20, 15, 12, 21, 12, 21)
          ..close();
        canvas.drawPath(heart, paint);
        break;
      case AppIconType.book:
        final book = Path()
          ..moveTo(12, 6)
          ..quadraticBezierTo(7.5, 4, 3, 5)
          ..lineTo(3, 20)
          ..quadraticBezierTo(7.5, 19, 12, 21)
          ..quadraticBezierTo(16.5, 19, 21, 20)
          ..lineTo(21, 5)
          ..quadraticBezierTo(16.5, 4, 12, 6)
          ..moveTo(12, 6)
          ..lineTo(12, 21);
        canvas.drawPath(book, paint);
        break;
      case AppIconType.user:
        canvas.drawCircle(const Offset(12, 8), 4, paint);
        canvas.drawPath(
          Path()..moveTo(4, 21)..cubicTo(4, 16, 20, 16, 20, 21),
          paint,
        );
        break;
      case AppIconType.shieldCheck:
        final shield = Path()
          ..moveTo(12, 2)
          ..lineTo(21, 6)
          ..lineTo(21, 12)
          ..cubicTo(21, 17, 17, 20, 12, 22)
          ..cubicTo(7, 20, 3, 17, 3, 12)
          ..lineTo(3, 6)
          ..close();
        canvas.drawPath(shield, paint);
        canvas.drawPath(Path()..moveTo(8, 12)..lineTo(11, 15)..lineTo(16, 9), paint);
        break;
      case AppIconType.sparkle:
        final sp = Path()
          ..moveTo(12, 2)
          ..lineTo(14.5, 9.5)
          ..lineTo(22, 12)
          ..lineTo(14.5, 14.5)
          ..lineTo(12, 22)
          ..lineTo(9.5, 14.5)
          ..lineTo(2, 12)
          ..lineTo(9.5, 9.5)
          ..close();
        canvas.drawPath(sp, paint);
        break;
      case AppIconType.mail:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3, 5, 18, 14), const Radius.circular(2)),
          paint,
        );
        canvas.drawPath(Path()..moveTo(3, 7)..lineTo(12, 14)..lineTo(21, 7), paint);
        break;
      case AppIconType.lock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(5, 10, 14, 11), const Radius.circular(2)),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(8, 10)
            ..lineTo(8, 7)
            ..arcToPoint(const Offset(16, 7), radius: const Radius.circular(4), clockwise: true)
            ..lineTo(16, 10),
          paint,
        );
        break;
      case AppIconType.search:
        canvas.drawCircle(const Offset(11, 11), 7, paint);
        canvas.drawPath(Path()..moveTo(16, 16)..lineTo(21, 21), paint);
        break;
      case AppIconType.clock:
        canvas.drawCircle(const Offset(12, 12), 9, paint);
        canvas.drawPath(Path()..moveTo(12, 6)..lineTo(12, 12)..lineTo(16, 14), paint);
        break;
      case AppIconType.editPen:
        canvas.drawPath(
          Path()
            ..moveTo(4, 20)
            ..lineTo(8, 19)
            ..lineTo(20, 7)
            ..lineTo(17, 4)
            ..lineTo(5, 16)
            ..close()
            ..moveTo(15, 6)
            ..lineTo(18, 9),
          paint,
        );
        break;
      case AppIconType.bookmark:
        canvas.drawPath(
          Path()..moveTo(6, 3)..lineTo(18, 3)..lineTo(18, 21)..lineTo(12, 17)..lineTo(6, 21)..close(),
          paint,
        );
        break;
      case AppIconType.star:
        final star = Path()
          ..moveTo(12, 2)
          ..lineTo(15.1, 8.3)
          ..lineTo(22, 9.3)
          ..lineTo(17, 14.2)
          ..lineTo(18.2, 21.2)
          ..lineTo(12, 18)
          ..lineTo(5.8, 21.2)
          ..lineTo(7, 14.2)
          ..lineTo(2, 9.3)
          ..lineTo(8.9, 8.3)
          ..close();
        canvas.drawPath(star, paint);
        break;
      case AppIconType.trash:
        canvas.drawPath(
          Path()
            ..moveTo(4, 7)
            ..lineTo(20, 7)
            ..moveTo(9, 7)
            ..lineTo(9, 4)
            ..lineTo(15, 4)
            ..lineTo(15, 7)
            ..moveTo(6, 7)
            ..lineTo(7, 21)
            ..lineTo(17, 21)
            ..lineTo(18, 7)
            ..moveTo(10, 11)
            ..lineTo(10, 18)
            ..moveTo(14, 11)
            ..lineTo(14, 18),
          paint,
        );
        break;
      case AppIconType.settingsGear:
        canvas.drawCircle(const Offset(12, 12), 3.2, paint);
        canvas.drawCircle(const Offset(12, 12), 8.2, paint);
        break;
      case AppIconType.wallet:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3, 6, 18, 15), const Radius.circular(3)),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(3, 10)
            ..lineTo(21, 10)
            ..moveTo(16, 15)
            ..lineTo(18, 15)
            ..moveTo(6, 6)
            ..lineTo(6, 4)
            ..lineTo(18, 4),
          paint,
        );
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
        canvas.drawPath(Path()..moveTo(8, 5)..lineTo(8, 19)..moveTo(16, 5)..lineTo(16, 19), paint);
        break;
      case AppIconType.checkMark:
        canvas.drawPath(Path()..moveTo(5, 12)..lineTo(9, 16)..lineTo(19, 6), paint);
        break;
      case AppIconType.noteLines:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(4, 3, 16, 18), const Radius.circular(2)),
          paint,
        );
        canvas.drawPath(
          Path()..moveTo(8, 9)..lineTo(16, 9)..moveTo(8, 13)..lineTo(16, 13)..moveTo(8, 17)..lineTo(12, 17),
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
