import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'app_animations.dart';
import 'app_icons.dart';

/// Wraps every screen in the warm gradient surface, centered phone width on desktop/web,
/// and edge-to-edge on mobile devices.
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

    if (!usePhoneFrame) {
      return Scaffold(
        backgroundColor: dark ? AppColors.voiceRadialEdge : AppColors.bgMid,
        body: inner,
      );
    }

    return Scaffold(
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
      padding: const EdgeInsets.fromLTRB(25, 8, 25, 0),
      child: SizedBox(
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 34,
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
                  size: 14,
                  weight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            SizedBox(
              width: 34,
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
        size: 10,
        weight: FontWeight.w800,
        color: AppColors.eyebrowPurple,
        letterSpacing: 1.5,
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
          weight: FontWeight.w800,
          color: AppColors.navy,
          height: 1.08,
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
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.inter(
              size: 10,
              weight: FontWeight.w800,
              color: AppColors.sectionLabel,
              letterSpacing: 1.25,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText!,
                style: AppTheme.inter(
                  size: 11,
                  weight: FontWeight.w700,
                  color: const Color(0xFF6575E4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool soft;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.soft = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: double.infinity,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: soft ? AppColors.softLav : AppColors.card,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: soft ? AppColors.softLavBorder : AppColors.cardBorder,
        ),
        boxShadow: soft ? null : AppShadows.card,
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

class TileIconBox extends StatelessWidget {
  final AppIconType icon;
  final bool blue;

  const TileIconBox({super.key, required this.icon, this.blue = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: blue ? AppColors.tileBlue : AppColors.tileNeutral,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: AppVectorIcon(
          icon,
          size: 19,
          color: blue ? AppColors.indigoEm : const Color(0xFF555B91),
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
      pressedScale: 0.88,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: 19,
        height: 19,
        decoration: BoxDecoration(
          color: checked ? AppColors.indigoEm : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: checked ? AppColors.indigoEm : const Color(0xFFC9CCDB),
            width: 1.5,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: checked
              ? const Center(
                  key: ValueKey('checked'),
                  child: AppVectorIcon(
                    AppIconType.checkMark,
                    size: 13,
                    color: Colors.white,
                    strokeWidth: 2.0,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.navyChip : AppColors.chipBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? AppColors.navyChip : AppColors.chipBorder,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTheme.inter(
            size: 10.5,
            weight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF746F78),
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
        height: 49,
        width: double.infinity,
        decoration: BoxDecoration(
          color: secondary ? AppColors.card : AppColors.navy,
          borderRadius: BorderRadius.circular(12),
          border: secondary ? Border.all(color: AppColors.secondaryBtnBorder) : null,
          boxShadow: secondary ? null : AppShadows.button,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: AppTheme.inter(
                size: 13,
                weight: FontWeight.w700,
                color: secondary ? AppColors.navy : Colors.white,
              ),
            ),
            Positioned(
              right: 17,
              child: AppVectorIcon(
                trailingIcon,
                size: 18,
                color: secondary ? AppColors.navy : Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.quoteLav,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AppVectorIcon(icon, size: 19, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTheme.inter(
                size: 10.5,
                weight: FontWeight.w500,
                color: const Color(0xFF626A8A),
                height: 1.4,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.phasePillBg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        'FUTURE FEATURE · PHASE 2',
        style: AppTheme.inter(
          size: 9,
          weight: FontWeight.w800,
          color: AppColors.phasePillText,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Exact 5-tab bottom navigation bar matching `.bottomnav` across Screens 07–22.
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

    return Container(
      height: 75 + bottomPad,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10 + bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: Color(0xFFE5DFDA))),
        boxShadow: AppShadows.bottomNav,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final selected = i == currentIndex;
          final color = selected ? AppColors.indigoNav : AppColors.navMuted;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 10 : 4,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFECEEFF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedScale(
                      scale: selected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: AppVectorIcon(tabs[i].icon, size: 21, color: color),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: AppTheme.inter(
                      size: 9.5,
                      weight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: color,
                    ),
                    child: Text(tabs[i].label),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
