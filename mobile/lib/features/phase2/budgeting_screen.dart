import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class BudgetingScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const BudgetingScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
  });

  int _spentFor(String category) {
    return appState.expenses
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .fold<int>(0, (s, e) => s + e.amount);
  }

  String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  String _currentMonthHeader() {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[DateTime.now().month - 1]} BUDGET';
  }

  @override
  Widget build(BuildContext context) {
    final spent = appState.totalBudgetSpent;
    final limit = appState.monthlyBudgetLimit;
    final ratio = (spent / (limit == 0 ? 1 : limit)).clamp(0.0, 1.0);

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
              title: 'Smart budgeting',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddExpense(context),
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
                      plainLine: 'Know where',
                      emphasizedLine: 'money goes.',
                    ),
                    const SizedBox(height: 16),
                    StaggeredReveal(
                      index: 0,
                      child: PremiumCard(
                        soft: true,
                        onTap: () => _showEditBudgetLimit(context),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _currentMonthHeader(),
                                  style: AppTheme.inter(
                                    size: 10,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF7F87B1),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const AppVectorIcon(
                                  AppIconType.editPen,
                                  size: 14,
                                  color: Color(0xFF7F87B1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Rs. ${_fmt(limit)}',
                                      style: AppTheme.inter(size: 28, weight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: limit >= spent
                                        ? AppColors.tileEmerald
                                        : AppColors.tileRose,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    limit >= spent
                                        ? 'Rs. ${_fmt(limit - spent)} left'
                                        : 'Over Rs. ${_fmt(spent - limit)}',
                                    style: AppTheme.inter(
                                      size: 10.5,
                                      weight: FontWeight.w700,
                                      color: limit >= spent
                                          ? AppColors.greenText
                                          : AppColors.roseAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rs. ${_fmt(spent)} spent of Rs. ${_fmt(limit)}',
                              style: AppTheme.inter(
                                size: 12,
                                weight: FontWeight.w600,
                                color: const Color(0xFF6B7094),
                              ),
                            ),
                            const SizedBox(height: 18),
                            LayoutBuilder(
                              builder: (_, c) => TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: ratio),
                                duration: const Duration(milliseconds: 620),
                                curve: Curves.easeOutCubic,
                                builder: (_, val, _) => Container(
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: AppColors.barTrack,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: c.maxWidth * val,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.progressFill,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'BY CATEGORY'),
                    StaggeredReveal(
                      index: 1,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            _BudgetCategoryRow(
                              icon: AppIconType.shoppingCart,
                              tone: TileTone.emerald,
                              title: 'Groceries',
                              subtitle: 'Rs. ${_fmt(_spentFor('Groceries'))} spent',
                              ratio: limit == 0 ? 0 : (_spentFor('Groceries') / limit).clamp(0.0, 1.0),
                              barColor: AppColors.greenSuccess,
                              onTap: () => _showCategorySheet(context, 'Groceries'),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _BudgetCategoryRow(
                              icon: AppIconType.wallet,
                              tone: TileTone.amber,
                              title: 'Bills',
                              subtitle: 'Rs. ${_fmt(_spentFor('Bills'))} spent',
                              ratio: limit == 0 ? 0 : (_spentFor('Bills') / limit).clamp(0.0, 1.0),
                              barColor: AppColors.amberAccent,
                              onTap: () => _showCategorySheet(context, 'Bills'),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _BudgetCategoryRow(
                              icon: AppIconType.heart,
                              tone: TileTone.rose,
                              title: 'Personal',
                              subtitle: 'Rs. ${_fmt(_spentFor('Personal'))} spent',
                              ratio: limit == 0 ? 0 : (_spentFor('Personal') / limit).clamp(0.0, 1.0),
                              barColor: AppColors.roseAccent,
                              onTap: () => _showCategorySheet(context, 'Personal'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'QUICK ACTIONS'),
                    StaggeredReveal(
                      index: 2,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showAddExpense(context),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 62),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    const TileIconBox(icon: AppIconType.plus),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Record an expense',
                                              style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                                          const SizedBox(height: 3),
                                          Text('“Spent Rs. 750 on lunch”',
                                              style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                                        ],
                                      ),
                                    ),
                                    const AppVectorIcon(
                                        AppIconType.chevronRight, size: 17, color: Color(0xFF74788C)),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            GestureDetector(
                              onTap: () {
                                appState.addExpense('Monthly Internet', 2500, 'Bills');
                                showAppToast(context, 'Added Monthly Internet (Rs. 2,500) to Bills');
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 62),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    const TileIconBox(icon: AppIconType.refresh),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Use last month’s template',
                                              style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                                          const SizedBox(height: 3),
                                          Text('Start with previous entries',
                                              style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                                        ],
                                      ),
                                    ),
                                    const AppVectorIcon(
                                        AppIconType.chevronRight, size: 17, color: Color(0xFF74788C)),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetLimit(BuildContext context) {
    final limitCtrl = TextEditingController(text: appState.monthlyBudgetLimit.toString());
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly budget limit', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: limitCtrl,
            label: 'Budget limit (Rs.)',
            hint: 'e.g. 50000',
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final preset in const [30000, 50000, 75000])
                AppChip(
                  label: 'Rs. ${_fmt(preset)}',
                  active: false,
                  onTap: () => limitCtrl.text = preset.toString(),
                ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Update limit',
            onTap: () {
              final next = int.tryParse(limitCtrl.text.trim()) ?? 0;
              if (next > 0) {
                appState.setMonthlyBudgetLimit(next);
                Navigator.pop(ctx);
                showAppToast(context, 'Budget set to Rs. ${_fmt(next)}');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context, String category) {
    final items = appState.expenses
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$category expenses', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Rs. ${_fmt(_spentFor(category))} spent total',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'No expenses recorded in $category yet.',
                style: AppTheme.inter(size: 12.5, color: AppColors.mutedText),
              ),
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTheme.inter(size: 13.5, weight: FontWeight.w700)),
                        Text(
                          'Rs. ${_fmt(item.amount)}',
                          style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      appState.deleteExpense(item.id);
                      Navigator.pop(ctx);
                      showAppToast(context, 'Removed “${item.title}”');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: AppVectorIcon(
                        AppIconType.trash,
                        size: 17,
                        color: Color(0xFFD65A5A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Add $category expense',
            onTap: () {
              Navigator.pop(ctx);
              _showAddExpense(context, initialCategory: category);
            },
          ),
        ],
      ),
    );
  }

  void _showAddExpense(BuildContext context, {String initialCategory = 'Personal'}) {
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String cat = initialCategory;
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record expense', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: titleCtrl,
              label: 'What did you spend on?',
              hint: 'e.g. Fresh groceries or lunch',
              autofocus: true,
            ),
            const SizedBox(height: 10),
            PremiumSheetField(
              controller: amtCtrl,
              label: 'Amount (Rs.)',
              hint: 'e.g. 750',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final c in const ['Groceries', 'Bills', 'Personal'])
                  AppChip(
                    label: c,
                    active: cat == c,
                    onTap: () => setModalState(() => cat = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save expense',
              onTap: () {
                final title = titleCtrl.text.trim().isEmpty ? '$cat expense' : titleCtrl.text.trim();
                final amount = int.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amount <= 0) return;
                appState.addExpense(title, amount, cat);
                Navigator.pop(ctx);
                showAppToast(context, 'Saved Rs. ${_fmt(amount)} ($cat)');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryRow extends StatelessWidget {
  final AppIconType icon;
  final TileTone tone;
  final String title;
  final String subtitle;
  final double ratio;
  final Color barColor;
  final VoidCallback onTap;

  const _BudgetCategoryRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.ratio,
    required this.barColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            TileIconBox(icon: icon, tone: tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(size: 13.5, weight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(size: 11, color: AppColors.subText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: AppColors.barTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const AppVectorIcon(AppIconType.moreDots, size: 18, color: Color(0xFF74788C)),
          ],
        ),
      ),
    );
  }
}
