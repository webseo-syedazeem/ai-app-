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
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: onBack,
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
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: const [
                            _FeatureRow(
                              icon: AppIconType.mic,
                              tone: TileTone.indigo,
                              title: 'Capture naturally',
                              subtitle: 'Speak or type whatever is on your mind',
                            ),
                            SizedBox(height: 10),
                            _FeatureRow(
                              icon: AppIconType.bell,
                              tone: TileTone.amber,
                              title: 'Remember what matters',
                              subtitle: 'Helpful, timely reminders',
                            ),
                            SizedBox(height: 10),
                            _FeatureRow(
                              icon: AppIconType.brain,
                              tone: TileTone.violet,
                              title: 'Find it later',
                              subtitle: 'Keep important notes in one place',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    StaggeredReveal(
                      index: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppGradients.darkAiCard,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.voiceFloat,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOICE EXAMPLE',
                              style: AppTheme.inter(
                                size: 9.5,
                                weight: FontWeight.w800,
                                color: const Color(0xFF9EA9FF),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '“Remind me to send the proposal tomorrow at 10.”',
                              style: AppTheme.inter(
                                size: 15,
                                weight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AppVectorIcon(
                                    AppIconType.checkCircle,
                                    size: 15,
                                    color: Color(0xFF6BE0B8),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Reminder ready to review',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.inter(
                                        size: 11,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFF8FF0CD),
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
  final TileTone tone;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.choose,
      ),
      child: Row(
        children: [
          TileIconBox(icon: icon, tone: tone, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.inter(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTheme.inter(size: 11.5, color: AppColors.subText),
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
