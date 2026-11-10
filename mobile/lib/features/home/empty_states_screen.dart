import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class EmptyStatesScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onCreateFirstTask;
  final VoidCallback onSpeakReminder;
  final ValueChanged<int> onSwitchTab;

  const EmptyStatesScreen({
    super.key,
    required this.onBack,
    required this.onCreateFirstTask,
    required this.onSpeakReminder,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Today',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 16, 25, 100),
                child: Column(
                  children: [
                    StaggeredReveal(
                      index: 0,
                      child: Container(
                        height: 205,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(0xFFECEEFF), Color(0x00ECEEFF)],
                          ),
                        ),
                        child: const Center(
                          child: FloatingBob(
                            amplitude: 4.5,
                            child: AppBrandMark(size: 88),
                          ),
                        ),
                      ),
                    ),
                    const HeroHeading(
                      plainLine: 'A fresh start',
                      emphasizedLine: 'looks good.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nothing is due today. Add a task or tell your assistant what’s on your mind.',
                      textAlign: TextAlign.center,
                      style: AppTheme.inter(
                        size: 13.5,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          _EmptyActionRow(
                            icon: AppIconType.plus,
                            title: 'Create your first task',
                            subtitle: 'A small step toward a clearer day',
                            onTap: onCreateFirstTask,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _EmptyActionRow(
                            icon: AppIconType.mic,
                            title: 'Speak a reminder',
                            subtitle: 'Just say what you need',
                            onTap: onSpeakReminder,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.quoteLav,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const AppVectorIcon(
                            AppIconType.sparkle,
                            size: 22,
                            color: AppColors.indigo,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Try “Remind me to call Ali tomorrow at 5.”',
                              style: AppTheme.inter(
                                size: 12,
                                color: const Color(0xFF626D9F),
                                height: 1.5,
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
    );
  }
}

class _EmptyActionRow extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EmptyActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            TileIconBox(icon: icon),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                ],
              ),
            ),
            const AppVectorIcon(AppIconType.chevronRight, size: 17, color: Color(0xFF74788C)),
          ],
        ),
      ),
    );
  }
}
