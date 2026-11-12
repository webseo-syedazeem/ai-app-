import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import 'app_animations.dart';
import 'app_icons.dart';

/// Wraps every screen in the warm atmospheric gradient surface, centered phone
/// width on desktop/web, and edge-to-edge on mobile devices.
class WarmScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomNav;
  final Widget? floatingOverlay;
  final bool dark;

  const WarmScaffold({
    super.key,
    required this.child,
    this.bottomNav,
    this.floatingOverlay,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final usePhoneFrame = screenWidth > 540;

    final inner = Container(
      decoration: BoxDecoration(
        gradient: dark ? AppGradients.voiceDark : AppGradients.screenWarm,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AmbientAuroraPainter(dark: dark),
              ),
            ),
          ),
          Positioned.fill(child: child),
          ?floatingOverlay,
          if (bottomNav != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomNav!,
            ),
        ],
      ),
    );

    final overlayStyle = dark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    if (!usePhoneFrame) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          backgroundColor: dark ? AppColors.voiceRadialEdge : AppColors.bgMid,
          body: inner,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFEBE5DC),
        body: Center(
          child: Container(
            width: 390,
            height: 844,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24171622),
                  blurRadius: 48,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: inner,
          ),
        ),
      ),
    );
  }
}

class _AmbientAuroraPainter extends CustomPainter {
  final bool dark;
  const _AmbientAuroraPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..color = dark ? const Color(0x2E5365DF) : const Color(0x55D9DFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.08), 160, topPaint);

    final bottomPaint = Paint()
      ..color = dark ? const Color(0x22784CE8) : const Color(0x4AFBE6D0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95);
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.78), 150, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant _AmbientAuroraPainter oldDelegate) => oldDelegate.dark != dark;
}

/// Crisp 38x38 squircle header action button (back, add, menu).
class AppHeaderIconBtn extends StatelessWidget {
  final AppIconType icon;
  final VoidCallback onTap;
  final bool accent;

  const AppHeaderIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.88,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: accent ? AppGradients.primaryBtn : null,
          color: accent ? null : AppColors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: accent ? const Color(0x28FFFFFF) : AppColors.cardBorder,
            width: 1.2,
          ),
          boxShadow: accent ? AppShadows.button : AppShadows.choose,
        ),
        child: Center(
          child: AppVectorIcon(
            icon,
            size: 19,
            strokeWidth: 2.5,
            color: accent ? Colors.white : AppColors.navy,
          ),
        ),
      ),
    );
  }
}

/// Exact 61px top header matching `.topline` in HTML designs.
class TopLineBar extends StatelessWidget {
  final Widget? left;
  final String title;
  final Widget? right;

  const TopLineBar({
    super.key,
    this.left,
    this.title = '',
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
      child: SizedBox(
        height: 52,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: left ?? const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.inter(
                  size: 16.5,
                  weight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            SizedBox(
              width: 44,
              child: Align(
                alignment: Alignment.centerRight,
                child: right ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EyebrowText extends StatelessWidget {
  final String text;
  const EyebrowText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.inter(
        size: 11,
        weight: FontWeight.w800,
        color: AppColors.eyebrowPurple,
        letterSpacing: 1.4,
      ),
    );
  }
}

class HeroHeading extends StatelessWidget {
  final String plainLine;
  final String emphasizedLine;
  final double size;
  final TextAlign textAlign;
  final Widget? trailing;

  const HeroHeading({
    super.key,
    required this.plainLine,
    required this.emphasizedLine,
    this.size = 38,
    this.textAlign = TextAlign.start,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTheme.inter(
          size: size,
          weight: FontWeight.w900,
          color: AppColors.navy,
          height: 1.06,
          letterSpacing: -1.8,
        ),
        children: [
          TextSpan(text: '$plainLine\n'),
          TextSpan(
            text: emphasizedLine,
            style: const TextStyle(color: AppColors.indigoEm),
          ),
          if (trailing != null) WidgetSpan(child: trailing!, alignment: PlaceholderAlignment.middle),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

class SectionLabelRow extends StatelessWidget {
  final String label;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionLabelRow({
    super.key,
    required this.label,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.inter(
                size: 11,
                weight: FontWeight.w800,
                color: AppColors.sectionLabel,
                letterSpacing: 1.25,
              ),
            ),
          ),
          if (actionText != null) ...[
            const SizedBox(width: 8),
            BouncyTap(
              onTap: onAction,
              pressedScale: 0.94,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tileBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softLavBorder),
                ),
                child: Text(
                  actionText!,
                  style: AppTheme.inter(
                    size: 11.5,
                    weight: FontWeight.w800,
                    color: AppColors.indigo,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool soft;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.soft = false,
    this.gradient,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(22);
    final container = Container(
      width: double.infinity,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: (soft || gradient != null) ? null : AppColors.card,
        gradient: gradient ?? (soft ? AppGradients.softLavCard : null),
        borderRadius: radius,
        border: Border.all(
          color: soft ? AppColors.softLavBorder : AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: soft ? AppShadows.softCard : AppShadows.card,
      ),
      child: child,
    );

    if (onTap == null) return container;
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.985,
      child: container,
    );
  }
}

enum TileTone { neutral, indigo, emerald, amber, rose, violet }

class TileIconBox extends StatelessWidget {
  final AppIconType icon;
  final bool blue;
  final TileTone? tone;
  final double size;

  const TileIconBox({
    super.key,
    required this.icon,
    this.blue = false,
    this.tone,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final effective = tone ?? (blue ? TileTone.indigo : TileTone.neutral);
    final (bg, iconColor, borderColor) = switch (effective) {
      TileTone.indigo => (AppColors.tileBlue, AppColors.indigoEm, const Color(0xFFC5C9FA)),
      TileTone.emerald => (AppColors.tileEmerald, AppColors.greenText, const Color(0xFFB3E5CD)),
      TileTone.amber => (AppColors.tileAmber, AppColors.amberAccent, const Color(0xFFF9D498)),
      TileTone.rose => (AppColors.tileRose, AppColors.roseAccent, const Color(0xFFF7BFC9)),
      TileTone.violet => (AppColors.tileViolet, AppColors.violetAccent, const Color(0xFFD4BAFA)),
      TileTone.neutral => (AppColors.tileNeutral, const Color(0xFF434873), const Color(0xFFDFD7CF)),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.15),
      ),
      child: Center(
        child: AppVectorIcon(
          icon,
          size: size * 0.54,
          strokeWidth: 2.45,
          color: iconColor,
        ),
      ),
    );
  }
}

class SquareCheck extends StatelessWidget {
  final bool checked;
  final VoidCallback? onTap;

  const SquareCheck({super.key, required this.checked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.86,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          gradient: checked ? AppGradients.accentIndigo : null,
          color: checked ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: checked ? Colors.transparent : const Color(0xFFC2C6D8),
            width: 1.6,
          ),
          boxShadow: checked
              ? const [
                  BoxShadow(
                    color: Color(0x305365DF),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: checked
              ? const Center(
                  key: ValueKey('checked'),
                  child: AppVectorIcon(
                    AppIconType.checkMark,
                    size: 13.5,
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.primaryBtn : null,
          color: active ? null : AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? AppColors.navyChip : AppColors.chipBorder,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x22171622),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : AppShadows.choose,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTheme.inter(
            size: 11.5,
            weight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF645F6C),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppIconType trailingIcon;
  final bool secondary;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.trailingIcon = AppIconType.arrowRight,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.975,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: secondary ? null : AppGradients.primaryBtn,
          color: secondary ? AppColors.card : null,
          borderRadius: BorderRadius.circular(16),
          border: secondary
              ? Border.all(color: AppColors.secondaryBtnBorder, width: 1.2)
              : Border.all(color: const Color(0x26FFFFFF), width: 1),
          boxShadow: secondary ? AppShadows.choose : AppShadows.button,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: AppTheme.inter(
                size: 14.5,
                weight: FontWeight.w800,
                color: secondary ? AppColors.navy : Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            Positioned(
              right: 12,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: secondary
                      ? AppColors.tileNeutral
                      : Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: AppVectorIcon(
                    trailingIcon,
                    size: 18,
                    strokeWidth: 2.5,
                    color: secondary ? AppColors.navy : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PagerDots extends StatelessWidget {
  final int activeIndex;
  final int count;

  const PagerDots({super.key, required this.activeIndex, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 21 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF657BF4) : const Color(0xFFDFE0E9),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class OnboardingStepper extends StatelessWidget {
  final int activeStep; // 1..3
  const OnboardingStepper({super.key, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < activeStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 39,
          height: 4,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFF6477F5) : const Color(0xFFE3E4EC),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class MiniBanner extends StatelessWidget {
  final AppIconType icon;
  final Color iconColor;
  final String text;

  const MiniBanner({
    super.key,
    required this.icon,
    this.iconColor = AppColors.indigoEm,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        gradient: AppGradients.softLavCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softLavBorder),
      ),
      child: Row(
        children: [
          TileIconBox(icon: icon, tone: TileTone.indigo, size: 34),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: AppTheme.inter(
                size: 12,
                weight: FontWeight.w600,
                color: const Color(0xFF474E78),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Phase2Pill extends StatelessWidget {
  const Phase2Pill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: AppGradients.softLavCard,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.softLavBorder),
      ),
      child: Text(
        'FUTURE FEATURE · PHASE 2',
        style: AppTheme.inter(
          size: 9.5,
          weight: FontWeight.w800,
          color: AppColors.phasePillText,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Signature translucent frosted bottom navigation bar with vibrant Speak emphasis.
class AppBottomNav extends StatelessWidget {
  final int currentIndex; // 0: Today, 1: Tasks, 2: Speak, 3: Shopping, 4: Memory
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const tabs = [
      (icon: AppIconType.calendar, label: 'Today'),
      (icon: AppIconType.checkCircle, label: 'Tasks'),
      (icon: AppIconType.mic, label: 'Speak'),
      (icon: AppIconType.shoppingCart, label: 'Shopping'),
      (icon: AppIconType.brain, label: 'Memory'),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 78 + bottomPad,
          padding: EdgeInsets.fromLTRB(8, 4, 8, 10 + bottomPad),
          decoration: const BoxDecoration(
            color: Color(0xECFFFEFB),
            border: Border(top: BorderSide(color: Color(0xFFE6DFD8))),
            boxShadow: AppShadows.bottomNav,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final selected = i == currentIndex;
              final isSpeak = i == 2;
              final color = selected ? AppColors.indigoNav : AppColors.navMuted;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: selected ? 13 : (isSpeak ? 10 : 6),
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSpeak && selected
                              ? AppGradients.accentIndigo
                              : (selected ? AppGradients.softLavCard : null),
                          color: isSpeak && !selected ? AppColors.tileBlue : null,
                          borderRadius: BorderRadius.circular(15),
                          border: selected && !isSpeak
                              ? Border.all(color: const Color(0xFFC4C9FA), width: 1.2)
                              : isSpeak && !selected
                                  ? Border.all(color: const Color(0xFFD4D7FB), width: 1.0)
                                  : null,
                          boxShadow: isSpeak && selected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x3E475BE0),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: AnimatedScale(
                          scale: selected ? 1.07 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: AppVectorIcon(
                            tabs[i].icon,
                            size: 22.5,
                            strokeWidth: selected || isSpeak ? 2.55 : 2.25,
                            color: isSpeak && selected
                                ? Colors.white
                                : (isSpeak ? AppColors.indigo : color),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: AppTheme.inter(
                          size: 10.8,
                          weight: selected || isSpeak ? FontWeight.w800 : FontWeight.w700,
                          color: isSpeak && !selected ? AppColors.indigoText : color,
                        ),
                        child: Text(tabs[i].label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

OverlayEntry? _activeToastEntry;

void showAppToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  if (_activeToastEntry?.mounted == true) {
    _activeToastEntry?.remove();
  }
  _activeToastEntry = null;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _TopToastOverlay(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismissed: () {
        if (_activeToastEntry == entry) {
          _activeToastEntry = null;
        }
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );
  _activeToastEntry = entry;
  overlay.insert(entry);
}

class _TopToastOverlay extends StatefulWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  const _TopToastOverlay({
    required this.message,
    this.actionLabel,
    this.onAction,
    required this.onDismissed,
  });

  @override
  State<_TopToastOverlay> createState() => _TopToastOverlayState();
}

class _TopToastOverlayState extends State<_TopToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_dismissed) {
          _dismissed = true;
          widget.onDismissed();
        }
      });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _closeNow() {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 10,
      left: 20,
      right: 20,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, child) {
              final t = _ctrl.value;
              final opacity = t < 0.12
                  ? Curves.easeOut.transform(t / 0.12)
                  : t > 0.85
                      ? Curves.easeIn.transform((1.0 - t) / 0.15)
                      : 1.0;
              final slideY = t < 0.12 ? (1.0 - opacity) * -14.0 : 0.0;
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, slideY),
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _closeNow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x28191720),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppVectorIcon(
                        AppIconType.checkCircle,
                        size: 16,
                        color: Color(0xFF9BA8FF),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppTheme.inter(
                            size: 12,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null && widget.onAction != null) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            widget.onAction!();
                            _closeNow();
                          },
                          child: Text(
                            widget.actionLabel!,
                            style: AppTheme.inter(
                              size: 12,
                              weight: FontWeight.w700,
                              color: const Color(0xFF9BA8FF),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showPremiumSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext sheetContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetCtx) {
      final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFDAD3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              builder(sheetCtx),
            ],
          ),
        ),
      );
    },
  );
}

class PremiumSheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool autofocus;

  const PremiumSheetField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.inter(size: 11, weight: FontWeight.w700)),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgTop,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: AppTheme.inter(size: 13, color: AppColors.navy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.inter(size: 12, color: const Color(0xFFAAA9B5)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class SheetActionRow extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const SheetActionRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.navy;
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.bgTop,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            AppVectorIcon(icon, size: 19, color: c),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 12.5, weight: FontWeight.w700, color: c)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                  ],
                ],
              ),
            ),
            AppVectorIcon(AppIconType.chevronRight, size: 16, color: c.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

