import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class ProductivityScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const ProductivityScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = appState.tasks.where((t) => t.completed).length;
    final completedGoals = appState.goals.where((g) => g.isCompleted).length;
    final score = (74 + completedTasks * 4 + completedGoals * 3).clamp(0, 100);
    const barHeights = [41.0, 66.0, 33.0, 72.0, 90.0, 49.0, 70.0];
    const barLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const barDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: onBack,
              ),
              title: 'Productivity insights',
              right: AppHeaderIconBtn(
                icon: AppIconType.moreDots,
                onTap: () => _showInsightsSheet(context, score, completedTasks, completedGoals),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Phase2Pill(),
                    const SizedBox(height: 12),
                    const HeroHeading(
                      plainLine: 'Celebrate',
                      emphasizedLine: 'your progress.',
                    ),
                    const SizedBox(height: 16),
                    StaggeredReveal(
                      index: 0,
                      child: PremiumCard(
                        soft: true,
                        onTap: () =>
                            _showInsightsSheet(context, score, completedTasks, completedGoals),
                        padding: const EdgeInsets.all(19),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: score / 100),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (_, val, _) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomPaint(
                                      size: const Size.square(110),
                                      painter: _ScorePainter(progress: val),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${(val * 100).round()}',
                                          style: AppTheme.inter(
                                            size: 27,
                                            weight: FontWeight.w800,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '/100',
                                          style: AppTheme.inter(
                                            size: 10,
                                            color: const Color(0xFF737EB7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'YOUR WEEK',
                                    style: AppTheme.inter(
                                      size: 10,
                                      weight: FontWeight.w800,
                                      color: const Color(0xFF737EB7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    score >= 85 ? 'Thriving' : 'On track',
                                    style: AppTheme.inter(size: 25, weight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Based on completed actions and goals',
                                    style: AppTheme.inter(
                                      size: 10.5,
                                      color: const Color(0xFF8B91B2),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'YOUR MOMENTUM'),
                    StaggeredReveal(
                      index: 1,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Column(
                          children: [
                            _MomentumRow(
                              icon: AppIconType.checkCircle,
                              tone: TileTone.emerald,
                              title: '${12 + completedTasks} tasks completed',
                              subtitle: 'This week',
                              onTap: () => onSwitchTab(1),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _MomentumRow(
                              icon: AppIconType.checkCircle,
                              tone: TileTone.indigo,
                              title: '${2 + completedGoals} goals achieved',
                              subtitle: 'This week',
                              onTap: () => _showInsightsSheet(
                                context,
                                score,
                                completedTasks,
                                completedGoals,
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _MomentumRow(
                              icon: AppIconType.star,
                              tone: TileTone.amber,
                              title: 'Consistency badge',
                              subtitle: 'Little wins count',
                              onTap: () => showAppToast(
                                context,
                                'Steady daily streak — keep capturing your thoughts!',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'WEEKLY ACTIVITY'),
                    StaggeredReveal(
                      index: 2,
                      child: PremiumCard(
                        padding: const EdgeInsets.all(14),
                        child: SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (i) {
                              return GestureDetector(
                                onTap: () => showAppToast(
                                  context,
                                  '${barDays[i]} activity: ${barHeights[i].round()}% focus score',
                                ),
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: barHeights[i]),
                                      duration: Duration(milliseconds: 420 + i * 70),
                                      curve: Curves.easeOutCubic,
                                      builder: (_, h, _) => Container(
                                        width: 22,
                                        height: h,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(6),
                                            bottom: Radius.circular(3),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Color(0xFF697DF8), Color(0xFFBAC3FE)],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      barLabels[i],
                                      style: AppTheme.inter(
                                        size: 10,
                                        color: const Color(0xFF9A9CAA),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
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

  void _showInsightsSheet(
    BuildContext context,
    int score,
    int completedTasks,
    int completedGoals,
  ) {
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly score: $score/100', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Your score rises as you finish daily tasks and hit personal milestones.',
            style: AppTheme.inter(size: 12.5, color: AppColors.mutedText, height: 1.5),
          ),
          const SizedBox(height: 14),
          SheetActionRow(
            icon: AppIconType.checkCircle,
            title: '${12 + completedTasks} tasks completed',
            subtitle: 'Tap to review your task list',
            color: AppColors.indigo,
            onTap: () {
              Navigator.pop(ctx);
              onSwitchTab(1);
            },
          ),
          SheetActionRow(
            icon: AppIconType.star,
            title: '${2 + completedGoals} goals achieved',
            subtitle: 'Friday was your peak focus day (90%)',
            color: AppColors.indigo,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

class _MomentumRow extends StatelessWidget {
  final AppIconType icon;
  final TileTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MomentumRow({
    required this.icon,
    this.tone = TileTone.neutral,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            TileIconBox(icon: icon, tone: tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTheme.inter(size: 11.5, color: AppColors.subText)),
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

class _ScorePainter extends CustomPainter {
  final double progress;
  _ScorePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFCBD1F8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = const Color(0xFF6074F3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );
  }

  @override
  bool shouldRepaint(covariant _ScorePainter oldDelegate) => oldDelegate.progress != progress;
}
