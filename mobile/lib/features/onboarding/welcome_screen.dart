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
              const SizedBox(height: 10),
              const StaggeredReveal(index: 0, child: AppBrandMark(size: 31)),
              const SizedBox(height: 28),
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
                    size: 13.5,
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
                      height: 265,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 240,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0xFFECEEFE), Color(0x00ECEEFE)],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 22,
                            top: 28,
                            child: FloatingBob(
                              amplitude: 4.5,
                              phaseOffset: 1.4,
                              duration: const Duration(milliseconds: 3200),
                              child: Transform.rotate(
                                angle: 14 * math.pi / 180,
                                child: Container(
                                  width: 132,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE7E3E9)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x2226243A),
                                        blurRadius: 40,
                                        offset: Offset(0, 18),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: AppVectorIcon(
                                      AppIconType.calendar,
                                      size: 28,
                                      color: Color(0xFF7186F4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            top: 42,
                            child: FloatingBob(
                              amplitude: 5.5,
                              duration: const Duration(milliseconds: 2800),
                              child: Transform.rotate(
                                angle: -5 * math.pi / 180,
                                child: Container(
                                  width: 250,
                                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE7E3E9)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x2226243A),
                                        blurRadius: 42,
                                        offset: Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const AppVectorIcon(
                                            AppIconType.checkCircle,
                                            size: 22,
                                            color: AppColors.indigo,
                                          ),
                                          const SizedBox(width: 9),
                                          Text(
                                            'Today’s plan',
                                            style: AppTheme.inter(
                                              size: 14,
                                              weight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      for (final item in const [
                                        'Call Ali at 5:00 PM',
                                        'Pick up groceries',
                                        'Finish project notes',
                                      ])
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F0FB),
                                            borderRadius: BorderRadius.circular(7),
                                          ),
                                          child: Text(
                                            item,
                                            style: AppTheme.inter(
                                              size: 10,
                                              weight: FontWeight.w500,
                                              color: const Color(0xFF6E728D),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 12,
                            child: FloatingBob(
                              amplitude: 6.0,
                              phaseOffset: 2.2,
                              duration: const Duration(milliseconds: 2400),
                              child: Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1C353968),
                                      blurRadius: 24,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const AppVectorIcon(
                                  AppIconType.sparkle,
                                  size: 22,
                                  color: AppColors.indigo,
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
                child: GestureDetector(
                  onTap: onSignIn,
                  child: Text.rich(
                    TextSpan(
                      style: AppTheme.inter(
                        size: 11.5,
                        color: const Color(0xFF8B8D9A),
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: AppTheme.inter(
                            size: 11.5,
                            weight: FontWeight.w700,
                            color: AppColors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
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
