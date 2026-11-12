import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              StaggeredReveal(
                index: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppBrandMark(size: 34),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppGradients.softLavCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softLavBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppVectorIcon(
                            AppIconType.sparkle,
                            size: 13,
                            color: AppColors.indigo,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'AI ASSISTANT',
                            style: AppTheme.inter(
                              size: 9.5,
                              weight: FontWeight.w800,
                              color: AppColors.indigoText,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const StaggeredReveal(
                index: 1,
                child: EyebrowText('YOUR EVERYDAY SECOND BRAIN'),
              ),
              const SizedBox(height: 14),
              const StaggeredReveal(
                index: 2,
                child: HeroHeading(
                  plainLine: 'More clarity.',
                  emphasizedLine: 'Less to\nremember.',
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              StaggeredReveal(
                index: 3,
                child: Text(
                  'Turn everyday thoughts into organized plans, helpful reminders and peace of mind.',
                  style: AppTheme.inter(
                    size: 14,
                    weight: FontWeight.w400,
                    color: AppColors.mutedText,
                    height: 1.55,
                  ),
                ),
              ),
              Expanded(
                child: StaggeredReveal(
                  index: 4,
                  child: Center(
                    child: SizedBox(
                      height: 270,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 290,
                            height: 250,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0xFFE3E7FF), Color(0x00E3E7FF)],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 18,
                            top: 24,
                            child: FloatingBob(
                              amplitude: 4.5,
                              phaseOffset: 1.4,
                              duration: const Duration(milliseconds: 3200),
                              child: Transform.rotate(
                                angle: 12 * math.pi / 180,
                                child: Container(
                                  width: 142,
                                  height: 180,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.softLavCard,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: AppColors.softLavBorder),
                                    boxShadow: AppShadows.softCard,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const TileIconBox(
                                        icon: AppIconType.calendar,
                                        tone: TileTone.indigo,
                                        size: 36,
                                      ),
                                      Text(
                                        'Nov\nSmart plan',
                                        textAlign: TextAlign.right,
                                        style: AppTheme.inter(
                                          size: 11,
                                          weight: FontWeight.w700,
                                          color: AppColors.indigoText,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 38,
                            child: FloatingBob(
                              amplitude: 5.5,
                              duration: const Duration(milliseconds: 2800),
                              child: Transform.rotate(
                                angle: -4.5 * math.pi / 180,
                                child: Container(
                                  width: 272,
                                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: AppColors.cardBorder),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1E26243A),
                                        blurRadius: 36,
                                        offset: Offset(0, 18),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const TileIconBox(
                                            icon: AppIconType.checkCircle,
                                            tone: TileTone.indigo,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 9),
                                          Expanded(
                                            child: Text(
                                              'Today’s plan',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTheme.inter(
                                                size: 14.5,
                                                weight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.tileEmerald,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'READY',
                                              style: AppTheme.inter(
                                                size: 8.5,
                                                weight: FontWeight.w800,
                                                color: AppColors.greenText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      for (final item in const [
                                        ('Call Ali at 5:00 PM', Color(0xFF5365DF)),
                                        ('Pick up groceries', Color(0xFF2FA37A)),
                                        ('Finish project notes', Color(0xFFD98718)),
                                      ])
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(top: 7),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 11, vertical: 9),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F4FC),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: item.$2,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item.$1,
                                                  style: AppTheme.inter(
                                                    size: 11.5,
                                                    weight: FontWeight.w600,
                                                    color: AppColors.navy,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 14,
                            top: 8,
                            child: FloatingBob(
                              amplitude: 6.0,
                              phaseOffset: 2.2,
                              duration: const Duration(milliseconds: 2400),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accentIndigo,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x365365DF),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const AppVectorIcon(
                                  AppIconType.sparkle,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const PagerDots(activeIndex: 0),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Get started',
                onTap: onGetStarted,
              ),
              const SizedBox(height: 14),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTheme.inter(
                        size: 12.5,
                        color: AppColors.mutedText,
                      ),
                    ),
                    BouncyTap(
                      onTap: onSignIn,
                      pressedScale: 0.94,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.tileBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Sign in',
                          style: AppTheme.inter(
                            size: 12,
                            weight: FontWeight.w800,
                            color: AppColors.indigo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}
