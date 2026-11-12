import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class GoalsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const GoalsScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _period = 'week';

  AppIconType _iconFor(String kind) {
    switch (kind) {
      case 'book':
        return AppIconType.book;
      case 'shopping':
        return AppIconType.shoppingCart;
      default:
        return AppIconType.briefcase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = widget.appState.goals.where((g) => g.period == _period).toList();
    final completedCount = goals.where((g) => g.isCompleted).length;
    final totalDisplay = _period == 'week' ? 4 : goals.length.clamp(1, 99);
    final achievedDisplay = _period == 'week' ? (completedCount + 1).clamp(0, 4) : completedCount;
    final ratio = totalDisplay == 0 ? 0.0 : (achievedDisplay / totalDisplay).clamp(0.0, 1.0);

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
              title: 'Goals & achievements',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddGoal(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Progress is',
                      emphasizedLine: 'personal.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Stay consistent with what matters to you.',
                      style: AppTheme.inter(size: 13.5, color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        AppChip(
                          label: 'This week',
                          active: _period == 'week',
                          onTap: () => setState(() => _period = 'week'),
                        ),
                        const SizedBox(width: 8),
                        AppChip(
                          label: 'This month',
                          active: _period == 'month',
                          onTap: () => setState(() => _period = 'month'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StaggeredReveal(
                      index: 0,
                      child: PremiumCard(
                        soft: true,
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _period == 'week' ? 'WEEKLY GOALS' : 'MONTHLY GOALS',
                                  style: AppTheme.inter(
                                    size: 9.5,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF7C83AF),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$achievedDisplay of $totalDisplay',
                                  style: AppTheme.inter(size: 30, weight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'goals achieved',
                                  style: AppTheme.inter(
                                    size: 11,
                                    color: const Color(0xFF8B8FB3),
                                  ),
                                ),
                              ],
                            ),
                            _DonutRing(
                              size: 87,
                              stroke: 11,
                              progress: ratio,
                              centerLabel: '${(ratio * 100).round()}%',
                              fontSize: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'YOUR GOALS'),
                    if (goals.isEmpty)
                      PremiumCard(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          'No $_period goals yet. Tap + in the top right to set one.',
                          style: AppTheme.inter(size: 12.5, color: AppColors.mutedText),
                        ),
                      ),
                    for (int i = 0; i < goals.length; i++)
                      StaggeredReveal(
                        index: i + 1,
                        child: GestureDetector(
                          onLongPress: () => _showGoalActions(context, goals[i]),
                          child: BouncyTap(
                            onTap: () {
                              final g = goals[i];
                              if (g.isCompleted) {
                                _showGoalActions(context, g);
                                return;
                              }
                              widget.appState.incrementGoal(g.id);
                              final done = g.currentValue + 1 >= g.targetValue;
                              showAppToast(
                                context,
                                done
                                    ? 'Goal achieved: ${g.title}!'
                                    : '+1 logged for “${g.title}”',
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                                boxShadow: AppShadows.card,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      TileIconBox(
                                        icon: _iconFor(goals[i].iconKind),
                                        tone: goals[i].isCompleted
                                            ? TileTone.emerald
                                            : TileTone.indigo,
                                        size: 40,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              goals[i].title,
                                              style: AppTheme.inter(size: 14, weight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              goals[i].isCompleted
                                                  ? 'Completed'
                                                  : '${goals[i].currentValue} of ${goals[i].targetValue} ${goals[i].unitLabel}',
                                              style: AppTheme.inter(
                                                  size: 11.5, color: AppColors.subText),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${goals[i].percent}%',
                                        style: AppTheme.inter(
                                          size: 14.5,
                                          weight: FontWeight.w900,
                                          color: AppColors.indigoText,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _showGoalActions(context, goals[i]),
                                        behavior: HitTestBehavior.opaque,
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: AppVectorIcon(
                                            AppIconType.moreDots,
                                            size: 17,
                                            color: Color(0xFF74788C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _GradientProgressBar(progress: goals[i].progress),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    StaggeredReveal(
                      index: goals.length + 1,
                      child: PremiumCard(
                        onTap: () => _showAchievementHistory(context),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const TileIconBox(icon: AppIconType.star),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Achievement history',
                                      style: AppTheme.inter(size: 14, weight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'See previous weeks and months',
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

  void _showGoalActions(BuildContext context, GoalModel goal) {
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.title, style: AppTheme.inter(size: 17, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${goal.currentValue} of ${goal.targetValue} ${goal.unitLabel} · ${goal.period == 'week' ? 'Weekly' : 'Monthly'}',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          if (!goal.isCompleted)
            SheetActionRow(
              icon: AppIconType.checkCircle,
              title: 'Log +1 progress',
              subtitle: 'Move toward ${goal.targetValue} ${goal.unitLabel}',
              color: AppColors.indigo,
              onTap: () {
                Navigator.pop(ctx);
                widget.appState.incrementGoal(goal.id);
                final done = goal.currentValue + 1 >= goal.targetValue;
                showAppToast(
                  context,
                  done ? 'Goal achieved: ${goal.title}!' : '+1 logged for “${goal.title}”',
                );
              },
            ),
          SheetActionRow(
            icon: AppIconType.trash,
            title: 'Remove goal',
            subtitle: 'Delete this goal from your list',
            color: const Color(0xFFD65A5A),
            onTap: () {
              Navigator.pop(ctx);
              widget.appState.deleteGoal(goal.id);
              showAppToast(context, 'Removed “${goal.title}”');
            },
          ),
        ],
      ),
    );
  }

  void _showAchievementHistory(BuildContext context) {
    final allGoals = widget.appState.goals;
    final completed = allGoals.where((g) => g.isCompleted).toList();
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievement history', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${completed.length} of ${allGoals.length} active goals completed overall',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          if (completed.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Keep tapping your goals as you make progress. Completed milestones appear right here.',
                style: AppTheme.inter(size: 12.5, color: AppColors.mutedText, height: 1.5),
              ),
            ),
          for (final g in completed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const AppVectorIcon(
                    AppIconType.checkCircle,
                    size: 18,
                    color: AppColors.indigo,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      g.title,
                      style: AppTheme.inter(size: 13.5, weight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    g.period == 'week' ? 'Weekly' : 'Monthly',
                    style: AppTheme.inter(size: 11, color: AppColors.subText),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Back to goals',
            secondary: true,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showAddGoal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '5');
    String period = _period;
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New goal', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: titleCtrl,
              label: 'Goal title',
              hint: 'e.g. Walk 20 mins',
              autofocus: true,
            ),
            const SizedBox(height: 10),
            PremiumSheetField(
              controller: targetCtrl,
              label: 'Target count',
              hint: 'e.g. 5',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                AppChip(
                  label: 'This week',
                  active: period == 'week',
                  onTap: () => setModalState(() => period = 'week'),
                ),
                AppChip(
                  label: 'This month',
                  active: period == 'month',
                  onTap: () => setModalState(() => period = 'month'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Create goal',
              onTap: () {
                final title = titleCtrl.text.trim();
                final target = (int.tryParse(targetCtrl.text.trim()) ?? 5).clamp(1, 999);
                if (title.isEmpty) return;
                widget.appState.addGoal(title, target, 'complete', period: period);
                setState(() => _period = period);
                Navigator.pop(ctx);
                showAppToast(context, 'Goal added: $title');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  final double progress;
  const _GradientProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 580),
        curve: Curves.easeOutCubic,
        builder: (_, val, _) => Container(
          height: 7,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.barTrack,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * val,
              height: 7,
              decoration: BoxDecoration(
                gradient: AppGradients.progressFill,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutRing extends StatelessWidget {
  final double size;
  final double stroke;
  final double progress;
  final String centerLabel;
  final double fontSize;

  const _DonutRing({
    required this.size,
    required this.stroke,
    required this.progress,
    required this.centerLabel,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (_, val, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(progress: val, stroke: stroke),
            ),
            Text(
              centerLabel,
              style: AppTheme.inter(size: fontSize, weight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double stroke;
  _RingPainter({required this.progress, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = const Color(0xFFCDD4FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final activePaint = Paint()
      ..color = const Color(0xFF6477F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
