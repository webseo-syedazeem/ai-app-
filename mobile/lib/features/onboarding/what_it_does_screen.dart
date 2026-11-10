import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class WhatItDoesScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const WhatItDoesScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StaggeredReveal(index: 0, child: EyebrowText('HOW IT WORKS')),
                    const SizedBox(height: 14),
                    const StaggeredReveal(
                      index: 1,
                      child: HeroHeading(
                        plainLine: 'Say it once.',
                        emphasizedLine: 'It’s organized.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaggeredReveal(
                      index: 2,
                      child: Text(
                        'No complicated forms. Just talk naturally and let your assistant handle the details.',
                        style: AppTheme.inter(
                          size: 13.5,
                          color: AppColors.mutedText,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    StaggeredReveal(
                      index: 3,
                      child: PremiumCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: const [
                            _FeatureRow(
                              icon: AppIconType.mic,
                              blue: true,
                              title: 'Capture naturally',
                              subtitle: 'Speak or type whatever is on your mind',
                            ),
                            SizedBox(height: 9),
                            _FeatureRow(
                              icon: AppIconType.bell,
                              title: 'Remember what matters',
                              subtitle: 'Helpful, timely reminders',
                            ),
                            SizedBox(height: 9),
                            _FeatureRow(
                              icon: AppIconType.brain,
                              title: 'Find it later',
                              subtitle: 'Keep important notes in one place',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StaggeredReveal(
                      index: 4,
                      child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: AppColors.quoteLav,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '“Remind me to send the proposal tomorrow at 10.”',
                            style: AppTheme.inter(
                              size: 14,
                              weight: FontWeight.w700,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Row(
                            children: [
                              const AppVectorIcon(
                                AppIconType.checkCircle,
                                size: 17,
                                color: Color(0xFF4AA687),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Reminder ready to review',
                                  style: AppTheme.inter(
                                    size: 10.5,
                                    weight: FontWeight.w700,
                                    color: AppColors.greenText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 8, 23, 24),
              child: Column(
                children: [
                  const PagerDots(activeIndex: 1),
                  const SizedBox(height: 18),
                  PrimaryButton(label: 'Continue', onTap: onContinue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final AppIconType icon;
  final bool blue;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    this.blue = false,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAE5E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08282034),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          TileIconBox(icon: icon, blue: blue),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.inter(size: 12.3, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                ),
              ],
            ),
          ),
          const AppVectorIcon(
            AppIconType.chevronRight,
            size: 17,
            color: Color(0xFF74788C),
          ),
        ],
      ),
    );
  }
}
