import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
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
              left: GestureDetector(
                onTap: widget.onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Goals & achievements',
              right: GestureDetector(
                onTap: () => _showAddGoal(context),
                child: const AppVectorIcon(AppIconType.plus, size: 21),
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
                    PremiumCard(
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
                    const SectionLabelRow(label: 'YOUR GOALS'),
                    for (final g in goals)
                      GestureDetector(
                        onTap: () => widget.appState.incrementGoal(g.id),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.tileBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: AppVectorIcon(
                                        _iconFor(g.iconKind),
                                        size: 18,
                                        color: AppColors.indigoEm,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          g.title,
                                          style: AppTheme.inter(size: 11.5, weight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          g.isCompleted
                                              ? 'Completed'
                                              : '${g.currentValue} of ${g.targetValue} ${g.unitLabel}',
                                          style: AppTheme.inter(size: 10, color: const Color(0xFF989BAA)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${g.percent}%',
                                    style: AppTheme.inter(
                                      size: 13,
                                      weight: FontWeight.w800,
                                      color: AppColors.indigoText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _GradientProgressBar(progress: g.progress),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    PremiumCard(
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
                                    style: AppTheme.inter(size: 12.3, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'See previous weeks and months',
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

  void _showAddGoal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '5');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('New goal', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Goal title (e.g. Walk 20 mins)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Target count (e.g. 5)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(targetCtrl.text.trim()) ?? 5;
              if (titleCtrl.text.trim().isNotEmpty) {
                widget.appState.addGoal(
                  titleCtrl.text.trim(),
                  target,
                  'complete',
                  period: _period,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
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
